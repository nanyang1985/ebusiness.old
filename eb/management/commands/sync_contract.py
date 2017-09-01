# coding: UTF-8
"""
Created on 2017/08/24

@author: Yang Wanjun
"""
import logging

from .base_batch import BaseBatch
from eb import biz_batch
from utils import constants

logger = logging.getLogger(__name__)


class Command(BaseBatch):
    BATCH_NAME = constants.BATCH_SYNC_CONTRACT
    BATCH_TITLE = u"契約自動更新"
    MAIL_TITLE = u"【営業支援システム】契約自動更新"

    def handle(self, *args, **options):
        username = options.get('username')

        logger.info(u"バッチ実行開始。username: %s" % username)
        biz_batch.batch_sync_contract(self.batch)
        logger.info(u"バッチ実行終了。username: %s" % username)

