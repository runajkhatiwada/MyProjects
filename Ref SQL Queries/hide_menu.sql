UPDATE setup_menu 
SET hide_show = 0
WHERE function_id in (
10201600,
10211400,
10101500,
10231000,
10131300,
10132300,
13240000,
12101700,
10235499,
13200000,
13190000,
13210000
)
	AND product_category = 10000000

UPDATE setup_menu
SET parent_menu_id = 10200000
WHERE function_id = 10164500
	AND product_category = 10000000