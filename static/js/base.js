function GetQueryString()
{
    var result = {};
    if( 1 < window.location.search.length )
    {
        // 最初の1文字 (?記号) を除いた文字列を取得する
        var query = window.location.search.substring( 1 );

        // クエリの区切り記号 (&) で文字列を配列に分割する
        var parameters = query.split( '&' );

        for( var i = 0; i < parameters.length; i++ )
        {
            // パラメータ名とパラメータ値に分割する
            var element = parameters[ i ].split( '=' );

            var paramName = decodeURIComponent( element[ 0 ] );
            var paramValue = decodeURIComponent( element[ 1 ] );

            // パラメータ名をキーとして連想配列に追加する
            result[ paramName ] = paramValue;
        }
    }
    return result;
}

function init_select(name)
{
    params = GetQueryString();
    value = params[name];
    if (value != null && value != undefined)
    {
        document.getElementById(name).value = value;
    }
}

function show_mask() {
    mask = $('#mask')
    mask.css('display', 'block');
    mask.css('width', $(document).width());
    mask.css('height', $(document).height());
}

function show_dialog(id_dialog) {
    show_mask();

    dialog = $('#' + id_dialog);
    dialog.css('display', 'block');
    top_position = ($(window).height() - dialog.height()) / 2;
    left_position = ($(window).width() - dialog.width()) / 2;
    dialog.css('top', top_position + "px");
    dialog.css('left', left_position + "px");
}

function hide_dialog(id_dialog) {
    $('#mask').css('display', 'none');
    dialog = $('.dialog');
    dialog.css('display', 'none');
}

function calc_extra_hours(obj) {
    price = $("#id_price").val();
    min_hours = $("#id_min_hours").val();
    max_hours = $("#id_max_hours").val();
    total_hours = $(obj).val();
    row_id = $(obj).parent().parent().attr("id");
    obj_extra_hours = $("#id_" + row_id + "-extra_hours");
    obj_plus = $("#id_" + row_id + "-plus_per_hour");
    obj_minus = $("#id_" + row_id + "-minus_per_hour");
    obj_value = $("#id_" + row_id + "-price");                     // 価格
    if (min_hours != "" && max_hours != "" && total_hours != "") {
        min_hours = parseFloat(min_hours);
        max_hours = parseFloat(max_hours);
        total_hours = parseFloat(total_hours);
        extra_hours = 0.00;
        if (total_hours > max_hours) {
            extra_hours = total_hours - max_hours;
        } else if (total_hours < min_hours) {
            extra_hours = total_hours - min_hours;
        }
        obj_extra_hours.val(extra_hours);

        // 増（円）と 減（円）
        price = parseFloat(price);
        plus_per_hour = Math.round(price / max_hours);
        minus_per_hour = Math.round(price / min_hours);
        obj_plus.val(plus_per_hour);
        obj_minus.val(minus_per_hour);

        // 最終価格
        if (extra_hours > 0) {
            result = price + extra_hours * plus_per_hour;
        }
        else if (extra_hours < 0) {
            result = price + extra_hours * minus_per_hour;
        } else {
            result = price;
        }
        obj_value.val(Math.round(result));
    }
}

function calc_price_for_plus(obj) {
    price = parseFloat($("#id_price").val());
    plus_per_hour = parseFloat($(obj).val());
    row_id = $(obj).parent().parent().attr("id");
    obj_extra_hours = $("#id_" + row_id + "-extra_hours");
    obj_value = $("#id_" + row_id + "-price");                     // 価格
    extra_hours = $(obj_extra_hours).val();
    if (extra_hours != "") {
        extra_hours = parseFloat(extra_hours);
        if (extra_hours > 0) {
            result = price + extra_hours * plus_per_hour;
            obj_value.val(Math.round(result));
        }
    }
}

function calc_price_for_minus(obj) {
    price = parseFloat($("#id_price").val());
    minus_per_hour = parseFloat($(obj).val());
    row_id = $(obj).parent().parent().attr("id");
    obj_extra_hours = $("#id_" + row_id + "-extra_hours");
    obj_value = $("#id_" + row_id + "-price");                     // 価格
    extra_hours = $(obj_extra_hours).val();
    if (extra_hours != "") {
        extra_hours = parseFloat(extra_hours);
        if (extra_hours < 0) {
            result = price + extra_hours * minus_per_hour;
            obj_value.val(Math.round(result));
        }
    }
}

function calc_extra_hours_portal(obj) {
    row_id = $(obj).parent().parent().attr("id");
    price = $("#" + row_id + "-basic_price").val();
    min_hours = $("#" + row_id + "-min_hours").val();
    max_hours = $("#" + row_id + "-max_hours").val();
    total_hours = $(obj).val();
    obj_extra_hours = $("#" + row_id + "-extra_hours");
    obj_plus = $("#" + row_id + "-plus_per_hour");
    obj_minus = $("#" + row_id + "-minus_per_hour");
    obj_value = $("#" + row_id + "-price");                     // 価格
    if (min_hours != "" && max_hours != "" && total_hours != "") {
        min_hours = parseFloat(min_hours);
        max_hours = parseFloat(max_hours);
        total_hours = parseFloat(total_hours);
        extra_hours = 0.00;
        if (total_hours > max_hours) {
            extra_hours = total_hours - max_hours;
        } else if (total_hours < min_hours) {
            extra_hours = total_hours - min_hours;
        }
        obj_extra_hours.val(extra_hours);

        // 増（円）と 減（円）
        price = parseFloat(price);
        plus_per_hour = Math.round(price / max_hours);
        minus_per_hour = Math.round(price / min_hours);
        obj_plus.val(plus_per_hour);
        obj_minus.val(minus_per_hour);

        // 最終価格
        if (extra_hours > 0) {
            result = price + extra_hours * plus_per_hour;
        }
        else if (extra_hours < 0) {
            result = price + extra_hours * minus_per_hour;
        } else {
            result = price;
        }
        obj_value.val(Math.round(result));
    }
}

function calc_price_for_plus_portal(obj) {
    row_id = $(obj).parent().parent().attr("id");
    price = parseFloat($("#" + row_id + "-basic_price").val());
    plus_per_hour = parseFloat($(obj).val());
    obj_extra_hours = $("#" + row_id + "-extra_hours");
    obj_value = $("#" + row_id + "-price");                     // 価格
    extra_hours = $(obj_extra_hours).val();
    if (extra_hours != "") {
        extra_hours = parseFloat(extra_hours);
        if (extra_hours > 0) {
            result = price + extra_hours * plus_per_hour;
            obj_value.val(Math.round(result));
        }
    }
}

function calc_price_for_minus_portal(obj) {
    row_id = $(obj).parent().parent().attr("id");
    price = parseFloat($("#" + row_id + "-basic_price").val());
    minus_per_hour = parseFloat($(obj).val());
    obj_extra_hours = $("#" + row_id + "-extra_hours");
    obj_value = $("#" + row_id + "-price");                     // 価格
    extra_hours = $(obj_extra_hours).val();
    if (extra_hours != "") {
        extra_hours = parseFloat(extra_hours);
        if (extra_hours < 0) {
            result = price + extra_hours * minus_per_hour;
            obj_value.val(Math.round(result));
        }
    }
}
