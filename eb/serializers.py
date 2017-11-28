# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from rest_framework import serializers

from . import models


class SubcontractorOrderRecipientSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.SubcontractorOrderRecipient
        fields = '__all__'
