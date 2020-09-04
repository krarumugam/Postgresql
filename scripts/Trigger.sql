CREATE TABLE PRODUCT_CATALOG1
(
  product_catalog1_id bigserial NOT NULL,
  product_catalog1_desc varchar(500) NOT NULL,
  active_flag boolean,
  sort_order integer,
  created_by varchar(150),
  created_date timestamp,
  updated_by varchar(150),
  updated_date timestamp
);

CREATE TABLE product_catalog1_audit(
	operation         		char(1)   NOT NULL,
	stamp             		timestamp NOT NULL,
	userid            		text      NOT NULL,
	product_catalog1_id 	bigserial NOT NULL,
	product_catalog1_desc 	varchar(500) NOT NULL,
	active_flag 			boolean,
	sort_order 				integer,
	created_by 				varchar(150),
	created_date	 		timestamp,
	updated_by 				varchar(150),
	updated_date 			timestamp
);

CREATE OR REPLACE FUNCTION audit_af_product_catalog1() RETURNS TRIGGER AS $product_catalog1_audit$
    BEGIN
        --
        -- Create a row in product_catalog1_audit to reflect the operation performed on product_catalog1,
        -- making use of the special variable TG_OP to work out the operation.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO public.product_catalog1_audit SELECT 'D', now(), user, OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO public.product_catalog1_audit SELECT 'U', now(), user, NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO public.product_catalog1_audit SELECT 'I', now(), user, NEW.*;
        END IF;
        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$product_catalog1_audit$ LANGUAGE plpgsql;

-- DROP TRIGGER trg_bf_product_catalog1 ON public.product_catalog1;

CREATE TRIGGER trg_af_product_catalog1 AFTER
INSERT OR DELETE OR UPDATE ON public.product_catalog1 
FOR EACH ROW EXECUTE PROCEDURE audit_af_product_catalog1();

CREATE OR REPLACE FUNCTION cr_upd_bf_product_catalog1() RETURNS TRIGGER AS $product_catalog1_audit$
	BEGIN
		--
		-- Insert created_date/updated_date based on the opertaion performed on product_catalog1
		-- making use of the special variable TG_OP to work out the operation.
		--
		IF (TG_OP = 'INSERT') THEN
			NEW.created_date := current_timestamp ;
			IF NEW.created_by IS NULL THEN
			NEW.created_by := user;
		    END IF;
		ELSIF (TG_OP = 'UPDATE') THEN
			NEW.updated_date := current_timestamp ;
			IF NEW.updated_by IS NULL THEN
			NEW.updated_by := user;
		    END IF;
		END IF;
	
		RETURN NEW;
	END;
$product_catalog1_audit$ LANGUAGE plpgsql;

CREATE TRIGGER trg_bf_product_catalog1 BEFORE
INSERT OR UPDATE ON public.product_catalog1 
FOR EACH ROW EXECUTE PROCEDURE cr_upd_bf_product_catalog1();
