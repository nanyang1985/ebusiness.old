# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from rest_framework import serializers

from . import models


class SubcontractorOrderRecipientSerializer(serializers.ModelSerializer):
    name = serializers.ReadOnlyField(source='subcontractor_member.name')
    email = serializers.ReadOnlyField(source='subcontractor_member.email')
    company_name = serializers.ReadOnlyField(source='subcontractor.name')

    class Meta:
        model = models.SubcontractorOrderRecipient
        fields = ('id', 'company_name', 'name', 'email', 'is_cc')


class MailTemplateSerializer(serializers.ModelSerializer):

    class Meta:
        model = models.MailTemplate
        fields = ('id', 'mail_title', 'mail_body', 'mail_html', 'pass_body')


class MailGroupSerializer(serializers.ModelSerializer):
    mail_template = MailTemplateSerializer()

    class Meta:
        model = models.MailGroup
        fields = ('id', 'name', 'title', 'mail_sender', 'mail_template')
