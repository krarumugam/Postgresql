do $$
<< mapping_block >>
declare
_column_list_a text[];
_column_list_t text[];
p_sort_order text := 'age desc';

begin

select array[	['load_id','loadId'],
				['age_of_load','age'],
				['equipment_name','equipmentName'],
				['load_type','loadType'],
				['load_status','loadStatus'],
				['origin_csz','originCsz'],
				['mileage','mileage'],
				['destination_csz','destinationCsz'],
				['customer_name','customerName'],
				['revenue_cost','revenueCost'],
				['actual_pickup_date','actualPickup'],
				['actual_delivery_date','actualDelivery']
			] into _column_list_a;

FOREACH _column_list_t SLICE 1 IN ARRAY _column_list_a
	        LOOP

                IF _column_list_t[2] = split_part( p_sort_order, ' ',1)
                	THEN
                		p_sort_order := concat(_column_list_t[1] , ' ', split_part( p_sort_order, ' ',2)); 
						RAISE NOTICE 'sort column : %', p_sort_order;	
				END IF;
		
		    END LOOP;

raise notice '%', _column_list_a;
END mapping_block $$;