# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.contrib.gis.geos import Point

from rest_framework import serializers
from rest_framework_gis.serializers import GeoFeatureModelSerializer, GeometrySerializerMethodField

from . import models


class SubcontractorOrderRecipientSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.SubcontractorOrderRecipient
        fields = '__all__'
