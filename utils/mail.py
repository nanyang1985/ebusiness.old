# -*- coding: UTF-8 -*-
from __future__ import unicode_literals
import os
import mimetypes
import datetime
import traceback
import pyminizip
import random
import string
import sys
import subprocess
import shutil

from email import encoders
from email.header import Header

from django.conf import settings
from django.core.mail import EmailMultiAlternatives, get_connection, SafeMIMEText
from django.core.mail.message import MIMEBase
from django.db import connection
from django.utils.encoding import smart_str

from utils.errors import CustomException
from utils import constants, common


logger = common.get_sales_logger()


class EbMail(object):

    def __init__(self, recipient_list=None, cc_list=None, attachment_list=None, is_encrypt=True,
                 mail_title=None, mail_body=None):
        self.recipient_list = EbMail.str_to_list(recipient_list)
        self.cc_list = EbMail.str_to_list(cc_list)
        self.attachment_list = attachment_list
        self.is_encrypt = is_encrypt
        self.mail_title = mail_title
        self.mail_body = mail_body
        self.password = None

    def check_recipient(self):
        if not self.recipient_list:
            raise CustomException("宛先はありません。")

    def check_attachment(self):
        if self.attachment_list:
            for attachment in self.attachment_list:
                if not os.path.exists(attachment):
                    raise CustomException("ファイル「%s」が見つかりません。" % attachment)

    def check_mail_title(self):
        if not self.mail_title:
            raise CustomException("メールの題名を設定してください。")

    @classmethod
    def get_mail_connection(cls):
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    "select value from mst_config where name = %s "
                    " union all "
                    "select value from mst_config where name = %s "
                    " union all "
                    "select value from mst_config where name = %s "
                    " union all "
                    "select value from mst_config where name = %s ",
                    [constants.CONFIG_ADMIN_EMAIL_SMTP_HOST, constants.CONFIG_ADMIN_EMAIL_SMTP_PORT,
                     constants.CONFIG_ADMIN_EMAIL_ADDRESS, constants.CONFIG_ADMIN_EMAIL_PASSWORD]
                )
                host, port, username, password = cursor.fetchall()
            backend = get_connection()
            backend.host = str(host[0])
            backend.port = int(port[0])
            backend.username = str(username[0])
            backend.password = str(password[0])
            return backend
        except Exception as ex:
            logger.error(unicode(ex))
            logger.error(traceback.format_exc())
            raise CustomException(unicode(ex))

    @classmethod
    def str_to_list(cls, s):
        if isinstance(s, basestring):
            return [i.strip() for i in s.split(',') if i]
        else:
            return s

    def zip_attachments(self):
        if self.attachment_list:
            temp_path = common.get_temp_path()
            temp_zip = os.path.join(temp_path, datetime.datetime.now().strftime('%Y%m%d%H%M%S%f.zip'))
            # TODO: エンコードが不一致しているので、暫定対策はＯＳごとに処理する。
            # if sys.platform == "win32":
            #     file_list = [f.encode('shift-jis') for f in self.attachment_list]
            # else:
            #     file_list = [f.encode('utf-8') for f in self.attachment_list]
            file_list = []
            if sys.platform == 'linux2':
                for f in file_list:
                    new_path = os.path.join(temp_path, os.path.dirname(f))
                    shutil.copy(f, new_path)
                    cmd = ['/usr/local/convmv-2.03/convmv', '--r', '--notest', '-f' 'utf-8' '-t', 'cp932', new_path]
                    subprocess.call(cmd, shell=False)
                    file_list.append(new_path)
            file_list = [f.encode('shift-jis') for f in self.attachment_list]
            password = self.generate_password()
            pyminizip.compress_multiple(file_list, temp_zip, password, 1)
            # # 文字コード変換
            # if sys.platform != "win32":
            #     try:
            #         cmd = ['7z', 'rn', temp_zip]
            #         for f in self.attachment_list:
            #             f_name = os.path.basename(f)
            #             cmd.append(f_name)
            #             cmd.append(f_name.encode('shift-jis'))
            #         subprocess.call(cmd, shell=False)
            #         logger.info("名称変更成功")
            #     except Exception:
            #         logger.info("名称変更失敗")
            bytes = open(temp_zip, b'rb',).read()
            os.remove(temp_zip)
            return bytes
        else:
            return None

    def generate_password(self, length=8):
        self.password = ''.join(random.choice(string.ascii_lowercase + string.digits) for _ in range(length))
        return self.password

    def send_email(self):
        self.check_recipient()
        self.check_attachment()
        self.check_mail_title()

        mail_connection = self.get_mail_connection()

        email = EmailMultiAlternativesWithEncoding(
            subject=self.mail_title,
            body=self.mail_body,
            from_email=mail_connection.username,
            to=self.recipient_list,
            cc=self.cc_list,
            connection=mail_connection
        )
        attachments = self.zip_attachments()
        if attachments:
            email.attach('%s.zip' % self.mail_title, attachments, constants.MIME_TYPE_ZIP)
        email.send()
        self.send_password(mail_connection)
        log_format = u"題名: %s; TO: %s; CC: %s; 送信完了。"
        logger.info(log_format % (self.mail_title, ','.join(self.recipient_list), ','.join(self.cc_list)))

    def send_password(self, conn):
        if self.attachment_list and self.is_encrypt:
            body = "先ほどメールのパスワードは以下になります：\n%s" % self.password
            email = EmailMultiAlternativesWithEncoding(
                subject=self.mail_title,
                body=body,
                from_email=conn.username,
                to=self.recipient_list,
                cc=self.cc_list,
                connection=conn
            )
            email.send()
            logger.info("%sのパスワードは送信しました。" % self.mail_title)


class EmailMultiAlternativesWithEncoding(EmailMultiAlternatives):
    def _create_attachment(self, filename, content, mimetype=None):
        """
        Converts the filename, content, mimetype triple into a MIME attachment
        object. Use self.encoding when handling text attachments.
        """
        if mimetype is None:
            mimetype, _ = mimetypes.guess_type(filename)
            if mimetype is None:
                mimetype = constants.MIME_TYPE_EXCEL
        basetype, subtype = mimetype.split('/', 1)
        if basetype == 'text':
            encoding = self.encoding or settings.DEFAULT_CHARSET
            attachment = SafeMIMEText(smart_str(content, settings.DEFAULT_CHARSET), subtype, encoding)
        else:
            # Encode non-text attachments with base64.
            attachment = MIMEBase(basetype, subtype)
            attachment.set_payload(content)
            encoders.encode_base64(attachment)
        if filename:
            try:
                filename = filename.encode('ascii')
            except UnicodeEncodeError:
                filename = Header(filename, 'utf-8').encode()
            attachment.add_header('Content-Disposition', 'attachment', filename=filename)
        return attachment
