# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from rest_framework import viewsets
from rest_framework.filters import SearchFilter

from . import models, serializers


# Create your views here.
class SubcontractorOrderRecipientViewSet(viewsets.ModelViewSet):
    queryset = models.SubcontractorOrderRecipient.objects.public_all()
    serializer_class = serializers.SubcontractorOrderRecipientSerializer
    filter_fields = ('subcontractor__id',)
