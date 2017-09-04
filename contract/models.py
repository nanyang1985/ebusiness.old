# coding: UTF-8
"""
Created on 2017/04/24

@author: Yang Wanjun
"""
from __future__ import unicode_literals
import datetime
import re

from django.db import models
from django.contrib.humanize.templatetags import humanize
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType

from eb.models import Member, Config, Company, Subcontractor, BatchManage
from utils import constants, common


class PublicManager(models.Manager):

    # use_for_related_fields = True

    def __init__(self, *args, **kwargs):
        super(PublicManager, self).__init__()
        self.args = args
        self.kwargs = kwargs

    def get_queryset(self):
        return super(PublicManager, self).get_queryset().filter(is_deleted=False)

    def public_all(self):
        return self.get_queryset().filter(*self.args, **self.kwargs)

    def public_filter(self, *args, **kwargs):
        return self.public_all().filter(*args, **kwargs)


class BaseModel(models.Model):
    created_date = models.DateTimeField(auto_now_add=True, null=True, editable=False, verbose_name=u"作成日時")
    updated_date = models.DateTimeField(auto_now=True, editable=False, verbose_name=u"更新日時")
    is_deleted = models.BooleanField(default=False, editable=False, verbose_name=u"削除フラグ")
    deleted_date = models.DateTimeField(blank=True, null=True, editable=False, verbose_name=u"削除年月日")

    objects = PublicManager(is_deleted=False)

    class Meta:
        abstract = True

    def delete(self, using=None, keep_parents=False):
        self.is_deleted = True
        self.deleted_date = datetime.datetime.now()
        self.save()


class Contract(BaseModel):
    member = models.ForeignKey(Member, editable=False, verbose_name=u"社員")
    company = models.ForeignKey(Company, verbose_name=u"雇用会社")
    contract_no = models.CharField(max_length=20, verbose_name=u"契約番号")
    contract_date = models.DateField(verbose_name=u"契約日", help_text=u"例：2014-01-01")
    member_type = models.IntegerField(choices=constants.CHOICE_MEMBER_TYPE, verbose_name=u"雇用形態")
    is_loan = models.BooleanField(default=False, verbose_name=u"出向")
    employment_date = models.DateField(verbose_name=u"雇用日", help_text=u"例：2014-01-01")
    start_date = models.DateField(verbose_name=u"雇用開始日")
    end_date = models.DateField(blank=True, null=True, verbose_name=u"雇用終了日")
    employment_period_comment = models.TextField(blank=True, null=True, verbose_name=u"雇用期間コメント",
                                                 default=Config.get_employment_period_comment())
    position = models.CharField(max_length=50, blank=True, null=True, verbose_name=u"職位")
    business_address = models.CharField(max_length=255, blank=True, null=True, default=Config.get_business_address(),
                                        verbose_name=u"就業の場所")
    business_type = models.CharField(max_length=2, choices=constants.CHOICE_BUSINESS_TYPE, verbose_name=u"業務の種類")
    business_type_other = models.CharField(blank=True, null=True, max_length=50, verbose_name=u"業務の種類その他")
    business_other = models.TextField(blank=True, null=True, default=Config.get_business_other(),
                                      verbose_name=u"業務その他")
    business_time = models.TextField(blank=True, null=True, default=Config.get_business_time(),
                                     verbose_name=u"就業時間")
    is_hourly_pay = models.BooleanField(default=False, verbose_name=u"時給")
    allowance_base = models.IntegerField(verbose_name=u"基本給")
    allowance_base_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"基本給メモ")
    allowance_base_other = models.IntegerField(default=0, verbose_name=u"基本給その他")
    allowance_base_other_memo = models.CharField(max_length=255, blank=True, null=True,
                                                 verbose_name=u"基本給その他メモ")
    allowance_work = models.IntegerField(default=0, verbose_name=u"現場手当")
    allowance_work_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"現場手当メモ")
    allowance_director = models.IntegerField(default=0, verbose_name=u"役職手当")
    allowance_director_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"役職手当メモ")
    allowance_position = models.IntegerField(default=0, verbose_name=u"職務手当")
    allowance_position_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"職務手当メモ")
    allowance_diligence = models.IntegerField(default=0, verbose_name=u"精勤手当")
    allowance_diligence_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"精勤手当メモ")
    allowance_security = models.IntegerField(default=0, verbose_name=u"安全手当")
    allowance_security_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"安全手当メモ")
    allowance_qualification = models.IntegerField(default=0, verbose_name=u"資格手当")
    allowance_qualification_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"資格手当メモ")
    allowance_traffic = models.IntegerField(default=0, verbose_name=u"通勤手当")
    allowance_traffic_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"通勤手当メモ")
    allowance_time_min = models.IntegerField(default=160, verbose_name=u"時間下限", help_text=u"足りないなら欠勤となる")
    allowance_time_max = models.IntegerField(default=200, verbose_name=u"時間上限", help_text=u"超えたら残業となる")
    allowance_overtime = models.IntegerField(default=0, verbose_name=u"残業手当")
    allowance_overtime_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"残業手当メモ")
    allowance_absenteeism = models.IntegerField(default=0, verbose_name=u"欠勤控除")
    allowance_absenteeism_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"欠勤手当メモ")
    allowance_other = models.IntegerField(default=0, verbose_name=u"その他手当")
    allowance_other_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"その他手当メモ")
    endowment_insurance = models.CharField(max_length=1, null=True, default='0',
                                           choices=constants.CHOICE_ENDOWMENT_INSURANCE,
                                           verbose_name=u"社会保険加入有無",
                                           help_text=u"0:加入しない、1:加入する")
    allowance_ticket_comment = models.TextField(blank=True, null=True, verbose_name=u"諸手当")
    allowance_date_comment = models.TextField(blank=True, null=True, default=Config.get_allowance_date_comment(),
                                              verbose_name=u"給与締め切り日及び支払日")
    allowance_change_comment = models.TextField(blank=True, null=True, default=Config.get_allowance_change_comment(),
                                                verbose_name=u"昇給及び降給")
    bonus_comment = models.TextField(blank=True, null=True, default=Config.get_bonus_comment(), verbose_name=u"賞与")
    holiday_comment = models.TextField(blank=True, null=True, default=Config.get_holiday_comment(), verbose_name=u"休日")
    paid_vacation_comment = models.TextField(blank=True, null=True, default=Config.get_paid_vacation_comment(),
                                             verbose_name=u"有給休暇")
    non_paid_vacation_comment = models.TextField(blank=True, null=True, default=Config.get_no_paid_vacation_comment(),
                                                 verbose_name=u"無給休暇")
    retire_comment = models.TextField(blank=True, null=True, default=Config.get_retire_comment(),
                                      verbose_name=u"退職に関する項目")
    status = models.CharField(max_length=2, default='01', choices=constants.CHOICE_CONTRACT_STATUS,
                              verbose_name=u"契約状態")
    comment = models.TextField(blank=True, null=True, default=Config.get_contract_comment(), verbose_name=u"備考")
    move_flg = models.BooleanField(default=0, editable=False)
    join_date = models.DateField(blank=True, null=True, verbose_name=u"入社年月日")
    retired_date = models.DateField(blank=True, null=True, verbose_name=u"退職年月日")
    end_date2 = models.DateField(blank=True, null=True, verbose_name=u"雇用終了日")

    class Meta:
        ordering = ['member', 'contract_no']
        verbose_name = verbose_name_plural = u"社員契約"
        db_table = 'eb_contract'

    def __unicode__(self):
        return u"%s(%s)" % (unicode(self.member), self.contract_no)

    def get_cost(self):
        """コストを取得する

        :return:
        """
        cost = self.allowance_base \
               + self.allowance_base_other \
               + self.allowance_work \
               + self.allowance_director \
               + self.allowance_position \
               + self.allowance_diligence \
               + self.allowance_security \
               + self.allowance_qualification \
               + self.allowance_other
        if self.member_type == 1:
            cost = int((cost * 14) / 12)
        return cost

    def get_cost_monthly(self):
        """在職証明書、所得証明書出力時、正社員の場合でも*14/12の必要はない
        
        :return: 
        """
        cost = self.allowance_base \
               + self.allowance_base_other \
               + self.allowance_work \
               + self.allowance_director \
               + self.allowance_position \
               + self.allowance_diligence \
               + self.allowance_security \
               + self.allowance_qualification \
               + self.allowance_other
        return cost

    def get_cost_yearly(self):
        """年収を取得する。

        :return:
        """
        cost = self.allowance_base \
               + self.allowance_base_other \
               + self.allowance_work \
               + self.allowance_director \
               + self.allowance_position \
               + self.allowance_diligence \
               + self.allowance_security \
               + self.allowance_qualification \
               + self.allowance_other
        if self.member_type == 1:
            return int(cost * 14)
        else:
            return cost * 12

    def get_next_contract_no(self):
        today = datetime.date.today()
        return "EB%04d%s" % (int(self.member.id_from_api), today.strftime('%Y%m%d'))

    def get_business_position(self):
        """在職証明書の職務位置に使われる

        :return:
        """
        business_type_name = self.get_business_type_display()
        m = re.search(r'（([^（）]+)）', business_type_name)
        if m and m.groups():
            return m.groups()[0]
        else:
            return business_type_name

    @property
    def is_fixed_cost(self):
        return False

    def save(self, force_insert=False, force_update=False, using=None,
             update_fields=None):
        if self.member.contract_set.filter(is_deleted=False).exclude(status='04').count() == 0:
            # 既存の契約が存在しない場合、入社日は契約開始日とする。
            self.join_date = self.start_date
        else:
            prev_contracts = self.member.contract_set.filter(
                is_deleted=False,
                start_date__lt=self.start_date
            ).exclude(status='04').order_by('-start_date')
            if prev_contracts.count() > 0:
                prev_contract = prev_contracts[0]
                if prev_contract.retired_date is not None:
                    # 前の契約の退職日はある場合、再び入社日を設定する。
                    self.join_date = self.start_date
                if prev_contract.member_type == 1 and prev_contract.end_date is None:
                    # 前の契約形態は正社員で、かつ雇用終了日は空白の場合。
                    prev_contract.end_date2 = self.start_date + datetime.timedelta(days=-1)
                    prev_contract.save(update_fields=['end_date2'])
        super(Contract, self).save(force_insert, force_update, using, update_fields)
        # from_email, title, body, html = self.get_formatted_batch(context)
        # mail_connection = BatchManage.get_custom_connection()
        # recipient_list = ContractRecipient.get_recipient_list()
        # cc_list = ContractRecipient.get_cc_list()
        # bcc_list = ContractRecipient.get_bcc_list()
        # email = EmailMultiAlternativesWithEncoding(
        #     subject=title,
        #     body=body,
        #     from_email=from_email,
        #     to=recipient_list,
        #     cc=cc_list,
        #     connection=mail_connection
        # )
        # if html:
        #     email.attach_alternative(html, constants.MIME_TYPE_HTML)
        # if attachments:
        #     for filename, content, mimetype in attachments:
        #         email.attach(filename, content, mimetype)
        # email.send()


class ContractRecipient(BaseModel):
    recipient_type = models.CharField(max_length=2, default='01', choices=constants.CHOICE_RECIPIENT_TYPE,
                                      verbose_name=u"送信種類")
    member = models.ForeignKey(Member, blank=True, null=True, verbose_name=u"送信先の社員")
    email = models.EmailField(blank=True, null=True, verbose_name=u"メールアドレス")

    class Meta:
        verbose_name = verbose_name_plural = u"契約変更の受信者"
        db_table = 'eb_contractrecipient'

    def __unicode__(self):
        if self.member:
            return unicode(self.member)
        else:
            return self.email

    @classmethod
    def get_recipient_list(cls):
        return ContractRecipient.objects.public_filter(recipient_type='01')

    @classmethod
    def get_cc_list(cls):
        return ContractRecipient.objects.public_filter(recipient_type='02')

    @classmethod
    def get_bcc_list(cls):
        return ContractRecipient.objects.public_filter(recipient_type='03')


class BpContract(BaseModel):
    member = models.ForeignKey(Member, verbose_name=u"社員")
    company = models.ForeignKey(Subcontractor, on_delete=models.PROTECT, verbose_name=u"雇用会社")
    member_type = models.IntegerField(default=4, editable=False, choices=constants.CHOICE_MEMBER_TYPE,
                                      verbose_name=u"雇用形態")
    start_date = models.DateField(verbose_name=u"雇用開始日")
    end_date = models.DateField(blank=True, null=True, verbose_name=u"雇用終了日")
    is_hourly_pay = models.BooleanField(default=False, verbose_name=u"時給")
    is_fixed_cost = models.BooleanField(default=False, verbose_name=u"固定")
    is_show_formula = models.BooleanField(default=True, verbose_name=u"計算式",
                                          help_text=u"注文書に超過単価と不足単価の計算式を表示するか")
    allowance_base = models.IntegerField(verbose_name=u"基本給")
    allowance_base_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"基本給メモ")
    allowance_time_min = models.DecimalField(default=160, max_digits=5, decimal_places=2, verbose_name=u"時間下限",
                                             help_text=u"足りないなら欠勤となる")
    allowance_time_max = models.DecimalField(default=200, max_digits=5, decimal_places=2, verbose_name=u"時間上限",
                                             help_text=u"超えたら残業となる")
    allowance_time_memo = models.CharField(max_length=255, blank=True, null=True,
                                           default=u"※基準時間：160～200/月", verbose_name=u"基準時間メモ")
    calculate_type = models.CharField(default='99', max_length=2, choices=constants.CHOICE_CALCULATE_TYPE,
                                      verbose_name=u"計算種類")
    business_days = models.IntegerField(blank=True, null=True, verbose_name=u"営業日数")
    calculate_time_min = models.DecimalField(blank=True, null=True, default=160, max_digits=5, decimal_places=2,
                                             verbose_name=u"計算用下限", help_text=u"欠勤手当を算出ために使われます。")
    calculate_time_max = models.DecimalField(blank=True, null=True, default=200, max_digits=5, decimal_places=2,
                                             verbose_name=u"計算用上限", help_text=u"残業手当を算出ために使われます。")
    allowance_overtime = models.IntegerField(default=0, verbose_name=u"残業手当")
    allowance_overtime_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"残業手当メモ")
    allowance_absenteeism = models.IntegerField(default=0, verbose_name=u"欠勤手当")
    allowance_absenteeism_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"欠勤手当メモ")
    allowance_other = models.IntegerField(default=0, verbose_name=u"その他手当")
    allowance_other_memo = models.CharField(max_length=255, blank=True, null=True, verbose_name=u"その他手当メモ")
    status = models.CharField(max_length=2, default='01', choices=constants.CHOICE_CONTRACT_STATUS,
                              verbose_name=u"契約状態")
    comment = models.TextField(blank=True, null=True,  verbose_name=u"備考")

    class Meta:
        ordering = ['company', 'member', 'start_date']
        verbose_name = verbose_name_plural = u"ＢＰ契約"
        db_table = 'eb_bp_contract'

    def __unicode__(self):
        return u"%s(%s)" % (unicode(self.member), self.start_date)

    def get_cost(self):
        """コストを取得する

        :return:
        """
        cost = self.allowance_base + self.allowance_other
        return cost

    @property
    def endowment_insurance(self):
        """他者技術者の場合、保険なし

        :return:
        """
        return '0'

    def get_allowance_time_min(self, year, month):
        if self.is_hourly_pay or self.is_fixed_cost:
            return 0
        elif self.calculate_type == '01':
            return 160
        elif self.calculate_type == '02':
            return len(common.get_business_days(year, month)) * 8
        elif self.calculate_type == '03':
            return len(common.get_business_days(year, month)) * 7.9
        else:
            return self.allowance_time_min

    def get_allowance_time_memo(self, year, month):
        allowance_time_min = self.get_allowance_time_min(year, month)
        if self.is_hourly_pay or self.is_fixed_cost:
            allowance_time_memo = ''
        elif self.calculate_type in ('01', '02', '03'):
            allowance_time_memo = u"※基準時間：%s～%sh/月" % (allowance_time_min, self.allowance_time_max)
        else:
            if self.allowance_time_memo:
                allowance_time_memo = self.allowance_time_memo
            else:
                allowance_time_memo = u"※基準時間：%s～%sh/月" % (allowance_time_min, self.allowance_time_max)
        return allowance_time_memo

    def get_allowance_absenteeism(self, year, month):
        if self.is_hourly_pay or self.is_fixed_cost:
            allowance_absenteeism = 0
        elif self.calculate_type in ('01', '02', '03'):
            allowance_time_min = self.get_allowance_time_min(year, month)
            allowance_absenteeism = int(int(self.allowance_base) / allowance_time_min)
            allowance_absenteeism -= allowance_absenteeism % 10
        else:
            allowance_absenteeism = self.allowance_absenteeism
        return allowance_absenteeism

    def get_allowance_absenteeism_memo(self, year, month):
        if self.is_hourly_pay or self.is_fixed_cost:
            allowance_absenteeism_memo = ''
        elif self.calculate_type in ('01', '02', '03'):
            allowance_time_min = self.get_allowance_time_min(year, month)
            allowance_absenteeism = self.get_allowance_absenteeism(year, month)
            allowance_absenteeism_memo = u"不足単価：¥%s/%sh=¥%s/h" % (
                humanize.intcomma(self.allowance_base), allowance_time_min, humanize.intcomma(allowance_absenteeism)
            )
        else:
            allowance_absenteeism_memo = self.allowance_absenteeism_memo
        return allowance_absenteeism_memo


class ViewContract(models.Model):
    contract_no = models.CharField(db_column='contract_no', max_length=20, verbose_name=u"契約番号")
    contract_date = models.DateField(db_column='contract_date', verbose_name=u"契約日", help_text=u"例：2014-01-01")
    member_type = models.IntegerField(db_column='member_type', choices=constants.CHOICE_MEMBER_TYPE,
                                      verbose_name=u"雇用形態")
    employment_date = models.DateField(db_column='employment_date', verbose_name=u"雇用日", help_text=u"例：2014-01-01")
    start_date = models.DateField(db_column='start_date', verbose_name=u"雇用開始日")
    end_date = models.DateField(db_column='end_date', blank=True, null=True, verbose_name=u"雇用終了日")
    employment_period_comment = models.TextField(db_column='employment_period_comment', blank=True, null=True,
                                                 verbose_name=u"雇用期間コメント",
                                                 default=Config.get_employment_period_comment())
    position = models.CharField(db_column='position', max_length=50, blank=True, null=True, verbose_name=u"職位")
    business_address = models.CharField(db_column='business_address', max_length=255, blank=True, null=True,
                                        default=Config.get_business_address(),
                                        verbose_name=u"就業の場所")
    business_type = models.CharField(db_column='business_type', max_length=2, choices=constants.CHOICE_BUSINESS_TYPE,
                                     verbose_name=u"業務の種類")
    business_type_other = models.CharField(db_column='business_type_other', blank=True, null=True, max_length=50,
                                           verbose_name=u"業務の種類その他")
    business_other = models.TextField(db_column='business_other', blank=True, null=True,
                                      default=Config.get_business_other(),
                                      verbose_name=u"業務その他")
    business_time = models.TextField(db_column='business_time', blank=True, null=True,
                                     default=Config.get_business_time(),
                                     verbose_name=u"就業時間")
    is_hourly_pay = models.BooleanField(db_column='is_hourly_pay', default=False, verbose_name=u"時給")
    is_fixed_cost = models.BooleanField(db_column='is_fixed_cost', default=False, verbose_name=u"固定")
    is_show_formula = models.BooleanField(db_column='is_show_formula', default=True, verbose_name=u"計算式",
                                          help_text=u"注文書に超過単価と不足単価の計算式を表示するか")
    allowance_base = models.IntegerField(db_column='allowance_base', verbose_name=u"基本給")
    allowance_base_memo = models.CharField(db_column='allowance_base_memo', max_length=255, blank=True, null=True,
                                           verbose_name=u"基本給メモ")
    allowance_base_other = models.IntegerField(db_column='allowance_base_other', default=0, verbose_name=u"基本給その他")
    allowance_base_other_memo = models.CharField(db_column='allowance_base_other_memo', max_length=255, blank=True,
                                                 null=True,
                                                 verbose_name=u"基本給その他メモ")
    allowance_work = models.IntegerField(db_column='allowance_work', default=0, verbose_name=u"現場手当")
    allowance_work_memo = models.CharField(db_column='allowance_work_memo', max_length=255, blank=True, null=True,
                                           verbose_name=u"現場手当メモ")
    allowance_director = models.IntegerField(db_column='allowance_director', default=0, verbose_name=u"役職手当")
    allowance_director_memo = models.CharField(db_column='allowance_director_memo', max_length=255, blank=True,
                                               null=True, verbose_name=u"役職手当メモ")
    allowance_position = models.IntegerField(db_column='allowance_position', default=0, verbose_name=u"職務手当")
    allowance_position_memo = models.CharField(db_column='allowance_position_memo', max_length=255, blank=True,
                                               null=True, verbose_name=u"職務手当メモ")
    allowance_diligence = models.IntegerField(db_column='allowance_diligence', default=0, verbose_name=u"精勤手当")
    allowance_diligence_memo = models.CharField(db_column='allowance_diligence_memo', max_length=255, blank=True,
                                                null=True, verbose_name=u"精勤手当メモ")
    allowance_security = models.IntegerField(db_column='allowance_security', default=0, verbose_name=u"安全手当")
    allowance_security_memo = models.CharField(db_column='allowance_security_memo', max_length=255, blank=True,
                                               null=True, verbose_name=u"安全手当メモ")
    allowance_qualification = models.IntegerField(db_column='allowance_qualification', default=0, verbose_name=u"資格手当")
    allowance_qualification_memo = models.CharField(db_column='allowance_qualification_memo', max_length=255,
                                                    blank=True, null=True, verbose_name=u"資格手当メモ")
    allowance_traffic = models.IntegerField(db_column='allowance_traffic', default=0, verbose_name=u"通勤手当")
    allowance_traffic_memo = models.CharField(db_column='allowance_traffic_memo', max_length=255, blank=True, null=True,
                                              verbose_name=u"通勤手当メモ")
    allowance_time_min = models.IntegerField(db_column='allowance_time_min', default=160, verbose_name=u"時間下限",
                                             help_text=u"足りないなら欠勤となる")
    allowance_time_max = models.IntegerField(db_column='allowance_time_max', default=200, verbose_name=u"時間上限",
                                             help_text=u"超えたら残業となる")
    allowance_time_memo = models.CharField(db_column='allowance_time_memo', max_length=255, blank=True, null=True,
                                           default=u"※基準時間：160～200/月", verbose_name=u"基準時間メモ")
    calculate_type = models.CharField(db_column='calculate_type', default='99', max_length=2,
                                      choices=constants.CHOICE_CALCULATE_TYPE,
                                      verbose_name=u"計算種類")
    calculate_time_min = models.DecimalField(db_column='calculate_time_min', blank=True, null=True, default=160,
                                             max_digits=5, decimal_places=2,
                                             verbose_name=u"計算用下限", help_text=u"欠勤手当を算出ために使われます。")
    calculate_time_max = models.DecimalField(db_column='calculate_time_max', blank=True, null=True, default=200,
                                             max_digits=5, decimal_places=2,
                                             verbose_name=u"計算用上限", help_text=u"残業手当を算出ために使われます。")
    allowance_overtime = models.IntegerField(db_column='allowance_overtime', default=0, verbose_name=u"残業手当")
    allowance_overtime_memo = models.CharField(db_column='allowance_overtime_memo', max_length=255, blank=True,
                                               null=True, verbose_name=u"残業手当メモ")
    allowance_absenteeism = models.IntegerField(db_column='allowance_absenteeism', default=0, verbose_name=u"欠勤控除")
    allowance_absenteeism_memo = models.CharField(db_column='allowance_absenteeism_memo', max_length=255, blank=True,
                                                  null=True, verbose_name=u"欠勤手当メモ")
    allowance_other = models.IntegerField(db_column='allowance_other', default=0, verbose_name=u"その他手当")
    allowance_other_memo = models.CharField(db_column='allowance_other_memo', max_length=255, blank=True, null=True,
                                            verbose_name=u"その他手当メモ")
    endowment_insurance = models.CharField(db_column='endowment_insurance', max_length=1, null=True, default='0',
                                           choices=constants.CHOICE_ENDOWMENT_INSURANCE,
                                           verbose_name=u"社会保険加入有無",
                                           help_text=u"0:加入しない、1:加入する")
    allowance_ticket_comment = models.TextField(db_column='allowance_ticket_comment', blank=True, null=True,
                                                verbose_name=u"諸手当")
    allowance_date_comment = models.TextField(db_column='allowance_date_comment', blank=True, null=True,
                                              default=Config.get_allowance_date_comment(),
                                              verbose_name=u"給与締め切り日及び支払日")
    allowance_change_comment = models.TextField(db_column='allowance_change_comment', blank=True, null=True,
                                                default=Config.get_allowance_change_comment(),
                                                verbose_name=u"昇給及び降給")
    bonus_comment = models.TextField(db_column='bonus_comment', blank=True, null=True,
                                     default=Config.get_bonus_comment(), verbose_name=u"賞与")
    holiday_comment = models.TextField(db_column='holiday_comment', blank=True, null=True,
                                       default=Config.get_holiday_comment(), verbose_name=u"休日")
    paid_vacation_comment = models.TextField(db_column='paid_vacation_comment', blank=True, null=True,
                                             default=Config.get_paid_vacation_comment(),
                                             verbose_name=u"有給休暇")
    non_paid_vacation_comment = models.TextField(db_column='non_paid_vacation_comment', blank=True, null=True,
                                                 default=Config.get_no_paid_vacation_comment(),
                                                 verbose_name=u"無給休暇")
    retire_comment = models.TextField(db_column='retire_comment', blank=True, null=True,
                                      default=Config.get_retire_comment(),
                                      verbose_name=u"退職に関する項目")
    status = models.CharField(db_column='status', max_length=2, default='01', choices=constants.CHOICE_CONTRACT_STATUS,
                              verbose_name=u"契約状態")
    comment = models.TextField(db_column='comment', blank=True, null=True, default=Config.get_contract_comment(),
                               verbose_name=u"備考")
    member = models.ForeignKey(Member, db_column='member_id', editable=False, verbose_name=u"社員")
    content_type = models.ForeignKey(ContentType, db_column='content_type_id', on_delete=models.PROTECT)
    company_id = models.PositiveIntegerField(db_column='company_id')
    content_object = GenericForeignKey('content_type', 'company_id')
    is_loan = models.BooleanField(db_column='is_loan', default=False, verbose_name=u"出向")
    move_flg = models.BooleanField(db_column='move_flg', default=0, editable=False)
    is_old = models.BooleanField(db_column='is_old', default=False, verbose_name=u"上書きされた契約")
    join_date = models.DateField(db_column='join_date', blank=True, null=True, verbose_name=u"入社年月日")
    retired_date = models.DateField(db_column='retired_date', blank=True, null=True, verbose_name=u"退職年月日")
    created_date = models.DateTimeField(db_column='created_date', null=True, editable=False, verbose_name=u"作成日時")
    updated_date = models.DateTimeField(db_column='updated_date', editable=False, verbose_name=u"更新日時")
    is_deleted = models.BooleanField(db_column='is_deleted', default=False, editable=False, verbose_name=u"削除フラグ")
    deleted_date = models.DateTimeField(db_column='deleted_date', blank=True, null=True, editable=False,
                                        verbose_name=u"削除年月日")

    objects = PublicManager(is_deleted=False)

    class Meta:
        managed = False
        db_table = 'v_contract'
        ordering = ['member', 'contract_no', 'start_date']
        verbose_name = verbose_name_plural = u"社員契約情報"
        default_permissions = ()

    def __unicode__(self):
        return unicode(self.member)

