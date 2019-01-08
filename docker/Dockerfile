FROM python:2.7-alpine
MAINTAINER Wang Xinguang <wangxinguang@e-business.co.jp>

WORKDIR /root

ADD . /root

RUN apk add --update git py-mysqldb mysql-dev gcc musl-dev
RUN apk add --no-cache --virtual .build-deps \
        build-base \
        g++ \
        python-dev \
        libpng-dev \
        freetype-dev \
        zlib \
        zlib-dev \
        jpeg \
        jpeg-dev
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
RUN apk add --no-cache xvfb ttf-freefont fontconfig dbus
RUN apk add qt5-qtbase-dev \
            wkhtmltopdf \
            --no-cache \
            --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
            --allow-untrusted
RUN pip --no-cache-dir install django==1.11.4 && \
    pip --no-cache-dir install djangorestframework==3.6.4 && \
    pip --no-cache-dir install django-filter==1.0.4 && \
    pip --no-cache-dir install crontab==0.22.0 && \
    pip --no-cache-dir install openpyxl==2.5.0 && \
    pip --no-cache-dir install xlsxwriter==1.0.2 && \
    pip --no-cache-dir install MySQL-python==1.2.5 && \
    pip --no-cache-dir install xlrd==1.1.0 && \
    pip --no-cache-dir install pdfkit==0.6.1 && \
    pip --no-cache-dir install pillow==4.3 && \
    pip --no-cache-dir install matplotlib==2.1.2 && \
    pip --no-cache-dir install requests==2.18.4 && \
    pip --no-cache-dir install qrcode && \
    pip --no-cache-dir install pyminizip && \
    pip --no-cache-dir install pandas==0.22.0 && \
    chmod +x /root/enterpoint.sh && \
    chmod +x /root/fix_error_matplotlib_display.sh && \
    chmod +x /root/fix_error_matplotlib_font.sh && \
    ln -s /root/wkhtmltopdf.sh /usr/local/bin/wkhtmltopdf && \
    apk del gcc musl-dev mysql-dev .build-deps && \
    rm -rf /var/cache/apk/*

# エラー修正
RUN sh /root/fix_error_matplotlib_display.sh && \
    sh /root/fix_error_matplotlib_font.sh

EXPOSE 80

ENTRYPOINT ["/root/enterpoint.sh"]
