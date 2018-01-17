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


class SubcontractorBankInfoSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.SubcontractorBankInfo
        fields = (
        'id', 'bank_code', 'bank_name', 'branch_no', 'branch_name', 'account_type', 'account_number', 'account_holder')


class SubcontractorSerializer(serializers.ModelSerializer):
    subcontractororderrecipient_set = SubcontractorOrderRecipientSerializer(many=True)
    subcontractorbankinfo_set = SubcontractorBankInfoSerializer(many=True)

    class Meta:
        model = models.Subcontractor
        fields = ('id', 'name', 'president', 'post_code', 'address1', 'address2', 'subcontractororderrecipient_set', 'subcontractorbankinfo_set')


class MailTemplateSerializer(serializers.ModelSerializer):

    class Meta:
        model = models.MailTemplate
        fields = ('id', 'mail_title', 'mail_body', 'mail_html', 'pass_body')


class MailCcListSerializer(serializers.ModelSerializer):
    name = serializers.SerializerMethodField()
    email = serializers.SerializerMethodField()

    class Meta:
        model = models.MailCcList
        fields = ('name', 'email',)

    def get_name(self, obj):
        if obj.member:
            return unicode(obj.member)
        else:
            return ""

    def get_email(self, obj):
        if obj.member and obj.member.email:
            return obj.member.email
        else:
            return obj.email


class MailGroupSerializer(serializers.ModelSerializer):
    mail_template = MailTemplateSerializer()
    mailcclist_set = MailCcListSerializer(many=True)

    class Meta:
        model = models.MailGroup
        fields = ('id', 'name', 'title', 'mail_sender', 'mail_template', 'mailcclist_set')


class MemberAttendanceSerializer(serializers.ModelSerializer):

    class Meta:
        model = models.MemberAttendance
        fields = '__all__'


class ProjectRequestDetailSerializer(serializers.ModelSerializer):

    class Meta:
        model = models.ProjectRequestDetail
        fields = '__all__'


class BpMemberOrderSerializer(serializers.ModelSerializer):

    class Meta:
        model = models.BpMemberOrder
        fields = '__all__'


class VClientRequestSerializer(serializers.ModelSerializer):

    class Meta:
        model = models.VClientRequest
        fields = ('year', 'month', 'amount', 'limit_date', 'turnover_amount', 'tax_amount', 'expenses_amount')


class ClientRequestSerializer(serializers.ModelSerializer):
    vclientrequest_set = VClientRequestSerializer(many=True)

    class Meta:
        model = models.Client
        fields = ('id', 'name', 'vclientrequest_set')


class VBpRequestSerializer(serializers.ModelSerializer):

    class Meta:
        model = models.VBpRequest
        fields = ('year', 'month', 'limit_date', 'amount', 'turnover_amount', 'tax_amount', 'expenses_amount')


class SubcontractorRequestSerializer(serializers.ModelSerializer):
    vbprequest_set = VBpRequestSerializer(many=True)

    class Meta:
        model = models.Client
        fields = ('id', 'name', 'vbprequest_set')
