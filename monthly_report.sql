#計算會員數量(七月新註冊 幾年加入新會員 今年以前加入的舊會員)
select count(distinct(member_id)) as 會員計數,
	case
		when date_format(date_add(member.create_time,interval 8 hour),'%Y%m%d') < 20210101 then '舊會員'
		when date_format(date_add(member.create_time,interval 8 hour),'%Y%m%d') between 20210701 and 20210731 then '本月新註冊會員'
        else '新會員'
	end as 會員狀態
from member
group by 會員狀態;

#會員計數 會員訂單
select order_info.buyer_id as 會員ID,sum(order_item.Net_Amount) as 訂單金額,count(distinct(order_info.order_id)) as 訂單數, 
	case
		when date_format(date_add(member.create_time,interval 8 hour),'%Y%m%d') < 20210101 then '舊會員'
        when date_format(date_add(member.create_time,interval 8 hour),'%Y%m%d') between 20210701 and 20210731 then '本月新註冊會員'
        else '新會員'
	end as 會員狀態

from order_info 
join order_item on order_item.order_id = order_info.order_id
join member on member.member_id = order_info.buyer_id
where date_format(date_add(order_info.create_time,interval 8 hour),'%Y%m%d') between 20210701 and 20210731
and order_info.order_status in (1,2)
and supp_id not in (772,910)
group by order_info.buyer_id;

#銷售關鍵字
select order_item.prod_name,sum(quantity),Category.path from order_item 
join product on product.prod_id = order_item.Prod_Id
join category on category.Category_Id = product.category_id
where date_format(date_add(order_item.create_time,interval 8 hour),'%Y%m%d') between 20210701 and 20210731
and order_item.order_status in (1,2)
group by order_item.prod_name;

#會員活躍度計算
select date_format(date_add(member_behavior.create_time,interval 8 hour),'%Y%m%d') as 日期,
count(distinct(member_behavior.member_id)) as 互動人數
from member_behavior
join member on member.member_id = member_behavior.Member_Id
and Behavior_Type in (0,2)
and date_format(date_add(member_behavior.create_time,interval 8 hour),'%Y%m%d') between 20210701 and 20210731
and date_format(date_add(member.create_time,interval 8 hour),'%Y%m%d') > 20201231
group by date_format(date_add(member_behavior.create_time,interval 8 hour),'%Y%m%d');


#銷售商品清單(來源)
select order_item.prod_id as 商品ID,order_item.prod_name as 商品名稱,
sum(quantity) as 銷量,sum(net_amount) as 營業額,count(distinct(item_no)) as 訂單數量,
	case
		when prod_name like '%《美安專屬》%' then '美安'
        when prod_name like '%《團》%' then '團購'
        when prod_name like '%夏普股東%' then '夏普'
        else '一般商品'
	end as 來源

from order_item 
where order_item.Order_Status in (1,2)
and date_format(date_add(order_item.create_time,interval 8 hour),'%Y%m%d') between 20210801 and 20210810
group by order_item.prod_id;


#計算不同來源商品業績
select date_format(date_add(order_item.create_time,interval 8 hour),'%Y/%m/%d') as 日期,sum(net_amount) as 營業額 from order_item
where order_item.Order_Status in (1,2)
and date_format(date_add(order_item.create_time,interval 8 hour),'%Y%m%d') between 20210701 and 20210731
and prod_name like '%《美安專屬》%'
group by date_format(date_add(order_item.create_time,interval 8 hour),'%Y/%m/%d');

#計算不同付款方式
select distinct(order_id)
from payment
where date_format(date_add(create_time,interval 8 hour),'%Y%m%d') between 20210701 and 20210731
and Paid_Time is not null
and type = 13;


# 1 = 信用卡 4 = ATM 10 = COCO 7 = 信用卡3期 13 = 折價券
select order_item.Item_no as 訂單編號,
	case
		when order_info.Payment_Type = 1 then '信用卡'
		when order_info.Payment_Type = 4 then 'ATM'
        when order_info.Payment_Type = 10 then 'COCO幣'
        when order_info.Payment_Type = 7 then '信用卡分期'
        else 0
	end as 付款方式

from order_item 
join order_info on order_info.order_id = order_item.order_id
where date_format(date_add(order_item.create_time,interval 8 hour),'%Y%m%d') between 20210701 and 20210731
and order_item.Order_Status in (1,2);

#折價券使用狀況
select distinct(order_id),
	case
		when order_id in (select distinct(order_id)
							from payment
							where date_format(date_add(create_time,interval 8 hour),'%Y%m%d') between 20210701 and 20210731
							and Paid_Time is not null
							and type = 13) then '使用折價券'
		else '未使用折價券'
	end as '折價券'
from order_info
where date_format(date_add(create_time,interval 8 hour),'%Y%m%d') between 20210701 and 20210731 
and Order_Status in (1,2);

