# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import get_object_or_404

from rest_framework import viewsets
from rest_framework.decorators import api_view
from rest_framework.response import Response

from . import models, serializers


# Create your views here.
class SubcontractorOrderRecipientViewSet(viewsets.ModelViewSet):
    queryset = models.SubcontractorOrderRecipient.objects.public_all()
    serializer_class = serializers.SubcontractorOrderRecipientSerializer
    filter_fields = ('subcontractor__id',)
    http_method_names = ['get']


class MailGroupViewSet(viewsets.ModelViewSet):
    queryset = models.MailGroup.objects.public_all()
    serializer_class = serializers.MailGroupSerializer
    http_method_names = ['get']


class SubcontractorViewSet(viewsets.ModelViewSet):
    queryset = models.Subcontractor.objects.public_all()
    serializer_class = serializers.SubcontractorSerializer
    http_method_names = ['get']


@api_view(['PUT'])
def subcontractor_order_sent(request, pk):
    bp_order = get_object_or_404(models.BpMemberOrder, pk=pk)

    if request.method == 'PUT':
        serializer = serializers.BpMemberOrderSerializer(bp_order)
        bp_order.is_sent = True
        bp_order.save()
        return Response(serializer.data)

class ClientRequestViewSet(viewsets.ModelViewSet):
    queryset = models.Client.objects.public_all()
    serializer_class = serializers.ClientSerializer
    http_method_names = ['get']
