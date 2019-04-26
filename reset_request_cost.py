# coding: UTF-8
import os
import django

from django.db import connection
from django.core.exceptions import ObjectDoesNotExist

from utils import common

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "employee.settings")
django.setup()


from eb.models import ProjectRequestDetail, MemberAttendance


def main():
    qs = ProjectRequestDetail.objects.all()
    for detail in qs:
        project_member = detail.project_member
        try:
            member_attendance = MemberAttendance.objects.get(
                project_member=project_member, year=detail.year, month=detail.month
            )
        except ObjectDoesNotExist:
            print u"出勤情報ありません：{}：アサインＩＤ：{}, {}年{}月".format(
                project_member.member, project_member.pk, detail.year, detail.month
            )
            continue
        try:
            with connection.cursor() as cursor:
                cursor.callproc('sp_project_member_cost', [
                    project_member.member.pk,
                    project_member.pk,
                    detail.year,
                    detail.month,
                    len(common.get_business_days(detail.year, detail.month)),
                    member_attendance.total_hours_bp or member_attendance.total_hours,
                    member_attendance.allowance or 0,
                    member_attendance.night_days or 0,
                    member_attendance.traffic_cost or 0,
                    detail.expenses_price,
                ])
                dict_cost = common.dictfetchall(cursor)[0]

            detail.salary = dict_cost.get('salary', 0) or 0
            detail.cost = dict_cost.get('cost', 0) or 0
            detail.save()
        except Exception as ex:
            print ex
            print u"エラー：{}：アサインＩＤ：{}, {}年{}月".format(
                project_member.member, project_member.pk, detail.year, detail.month
            )


if __name__ == '__main__':
    main()
