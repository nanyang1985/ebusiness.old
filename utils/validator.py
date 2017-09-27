# coding: UTF-8
"""
Created on 2017/09/27

@author: Yang Wanjun
"""
from __future__ import unicode_literals

from django.core.exceptions import ValidationError


def validate_rate(value):
    if value > 1 or value < 0:
        raise ValidationError('%sは０以上１以下でなければなりません。', params={'value': value})
