# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import get_object_or_404

from rest_framework import viewsets
from rest_framework.decorators import api_view
from rest_framework.response import Response

from . import models, serializers


# Create your views here.
class SubcontractorOrderRecipientViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = models.SubcontractorOrderRecipient.objects.public_all()
    serializer_class = serializers.SubcontractorOrderRecipientSerializer
    filter_fields = ('subcontractor__id',)


class MailGroupViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = models.MailGroup.objects.public_all()
    serializer_class = serializers.MailGroupSerializer


class SubcontractorViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = models.Subcontractor.objects.public_all()
    serializer_class = serializers.SubcontractorSerializer


@api_view(['PUT'])
def subcontractor_order_sent(request, pk):
    bp_order = get_object_or_404(models.BpMemberOrder, pk=pk)

    if request.method == 'PUT':
        serializer = serializers.BpMemberOrderSerializer(bp_order)
        bp_order.is_sent = True
        bp_order.save()
        return Response(serializer.data)

class ClientRequestViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = models.Client.objects.public_all()
    serializer_class = serializers.ClientRequestSerializer
    # http_method_names = ['get', 'head', 'options']


class SubcontractorRequestViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = models.Subcontractor.objects.public_all()
    serializer_class = serializers.SubcontractorRequestSerializer
    # http_method_names = ['get', 'head', 'options']
