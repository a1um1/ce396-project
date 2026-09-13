-- SQL dump generated using DBML (dbml.dbdiagram.io)
-- Database: PostgreSQL
-- Generated at: 2026-09-13T07:12:18.944Z

CREATE TABLE "users" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "name" varchar(100),
  "email" varchar(150) UNIQUE,
  "password_hash" varchar(255),
  "profile_image" varchar(255),
  "created_at" timestamptz,
  "update_at" timestamptz
);

CREATE TABLE "Phon_user" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid,
  "phone_number" varchar(20) UNIQUE
);

CREATE TABLE "Grab" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "company_name" varchar(150),
  "registration_number" varchar(30),
  "adress" varchar(255),
  "commission_rate" numeric(5,2)
);

CREATE TABLE "Rider" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid,
  "id_card_number" varchar2(20),
  "status" varchar(20),
  "total_rides" int,
  "created_at" timestamptz
);

CREATE TABLE "RideRequest" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid,
  "vehicle_type_id" uuid,
  "pickup_lat" numeric(9,6),
  "pickup_lng" numeric(9,6),
  "pickup_address" varchar(255),
  "dropoff_lat" numeric(9,6),
  "dropoff_lng" numeric(9,6),
  "dropoff_address" varchar(255),
  "status" varchar(20),
  "requested_at" timestamptz
);

CREATE TABLE "RideHistory" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "ride_request_id" uuid,
  "user_id" uuid,
  "rider_id" uuid,
  "vehicle_id" uuid,
  "distance_km" numeric(6,2),
  "duration_min" int,
  "base_price" numeric(10,2),
  "final_price" numeric(10,2),
  "start_time" timestamptz,
  "end_time" timestamptz,
  "status" varchar(20)
);

CREATE TABLE "Review" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "ride_history_id" uuid UNIQUE,
  "rating" int,
  "comment" text(65535),
  "created_at" timestamptz
);

CREATE TABLE "Payment History" (
  "id" uuid PRIMARY KEY NOT NULL,
  "ride_history_id" uuid,
  "payment_method_id" uuid,
  "amount" numeric(10,2),
  "status" varchar(20),
  "paid_at" timestamptz
);

CREATE TABLE "Payment Methods" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid,
  "type" varchar(20),
  "provider" varchar(50),
  "account_nimber" varchar(30),
  "is_default" boolean
);

CREATE TABLE "Discount History" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "payment_history_id" uuid,
  "discount_id" uuid,
  "discount_amount" numeric(10,2),
  "applied_at" timestamptz
);

CREATE TABLE "Discount" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "code" varchar(30) UNIQUE,
  "description" varchar(255),
  "discount_type" varchar(10),
  "value" numeric(10,2),
  "valid_from" timestamptz,
  "valid_to" timestamptz
);

CREATE TABLE "Vehicles" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "rider_id" uuid,
  "vehicle_type_id" uuid,
  "license_plate" varchar(15) UNIQUE,
  "brand" varchar(50),
  "model" varchar(50),
  "color" varchar(30),
  "year" int,
  "status" varchar(20)
);

CREATE TABLE "GovermentDocuments" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "rider_id" uuid,
  "document_type" varchar(3),
  "document_number" varchar(30),
  "file_url" varchar(255),
  "verification_status" varchar(20),
  "verified_at" timestamptz,
  "expiry_date" date
);

CREATE TABLE "VechiclesTypes" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "name" varchar(50),
  "description" varchar(255),
  "base_fare" numeric(10,2),
  "price_per_km" numeric(10,2),
  "capacity" int
);

CREATE TABLE "DistanceToPrice" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "min_distance_km" numeric(6,2),
  "max_distance_km" numeric(6,2),
  "price_per_km" numeric(10,2)
);

CREATE TABLE "TimePriceMultiplier" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "name" varchar(50),
  "start_time" time,
  "end_time" time,
  "multiplier" numeric(4,2)
);

CREATE TABLE "Audit Log" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "table_name" varchar(50),
  "record_id" uuid,
  "old_value" text(65535),
  "new_value" text(65535),
  "created_at" datetime
);

ALTER TABLE "Rider"
	ADD CONSTRAINT "fk_Rider_user_id _users"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "GovermentDocuments"
	ADD CONSTRAINT "fk_GovermentDocuments_rider_id_Rider"
	FOREIGN KEY ("rider_id")
	REFERENCES "Rider" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "Vehicles"
	ADD CONSTRAINT "fk_Vehicles_rider_id_Rider"
	FOREIGN KEY ("rider_id")
	REFERENCES "Rider" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "Vehicles"
	ADD CONSTRAINT "fk_Vehicles_vehicle_type_id_VechiclesTypes"
	FOREIGN KEY ("vehicle_type_id")
	REFERENCES "VechiclesTypes" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "RideRequest"
	ADD CONSTRAINT "fk_RideRequest_user_id _users"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "RideHistory"
	ADD CONSTRAINT "fk_RideHistory_ride_request_id_RideRequest"
	FOREIGN KEY ("ride_request_id")
	REFERENCES "RideRequest" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "RideHistory"
	ADD CONSTRAINT "fk_RideHistory_user_id_users"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "RideHistory"
	ADD CONSTRAINT "fk_RideHistory_rider_id_Rider"
	FOREIGN KEY ("rider_id")
	REFERENCES "Rider" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "RideHistory"
	ADD CONSTRAINT "fk_RideHistory_vehicle_id_Vehicles"
	FOREIGN KEY ("vehicle_id")
	REFERENCES "Vehicles" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "Payment Methods"
	ADD CONSTRAINT "fk_users_id_Payment Methods"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "Payment History"
	ADD CONSTRAINT "fk_Payment History_ride_history_id_RideHistory"
	FOREIGN KEY ("ride_history_id")
	REFERENCES "RideHistory" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "Payment History"
	ADD CONSTRAINT "fk_Payment History_payment_method_id_Payment Methods"
	FOREIGN KEY ("payment_method_id")
	REFERENCES "Payment Methods" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "Review"
	ADD CONSTRAINT "fk_Review_ride_history_id_Payment History"
	FOREIGN KEY ("ride_history_id")
	REFERENCES "Payment History" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "Discount History"
	ADD CONSTRAINT "fk_Discount History_payment_history_id_Payment History"
	FOREIGN KEY ("payment_history_id")
	REFERENCES "Payment History" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "Discount History"
	ADD CONSTRAINT "fk_Discount History_discount_id_Discount"
	FOREIGN KEY ("discount_id")
	REFERENCES "Discount" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

ALTER TABLE "Phon_user"
	ADD CONSTRAINT "fk_Phon_user_user_id_users"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;
