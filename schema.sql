-- SQL dump generated using DBML (dbml.dbdiagram.io)
-- Database: PostgreSQL
-- Generated at: 2026-09-14T06:21:30.882Z

CREATE TABLE "users" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "name" varchar(100) NOT NULL,
  "email" varchar(150) UNIQUE NOT NULL,
  "password_hash" varchar(255) NOT NULL,
  "profile_image" varchar(255) NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (now()),
  "update_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "Phone_user" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid NOT NULL,
  "phone_number" varchar(20) UNIQUE NOT NULL
);

CREATE TABLE "Rider" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid UNIQUE NOT NULL,
  "status" varchar(20) NOT NULL,
  "total_rides" int NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "RideRequest" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid NOT NULL,
  "vehicle_type_id" uuid NOT NULL,
  "pickup_lat" numeric(9,6) NOT NULL,
  "pickup_lng" numeric(9,6) NOT NULL,
  "pickup_address" varchar(255) NOT NULL,
  "dropoff_lat" numeric(9,6) NOT NULL,
  "dropoff_lng" numeric(9,6) NOT NULL,
  "dropoff_address" varchar(255) NOT NULL,
  "status" varchar(20) NOT NULL,
  "requested_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "RideHistory" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "ride_request_id" uuid NOT NULL,
  "user_id" uuid NOT NULL,
  "rider_id" uuid NOT NULL,
  "vehicle_id" uuid NOT NULL,
  "distance_km" numeric(6,2) NOT NULL,
  "duration_min" int NOT NULL,
  "base_price" numeric(10,2) NOT NULL,
  "final_price" numeric(10,2) NOT NULL,
  "start_time" timestamptz NOT NULL DEFAULT (now()),
  "end_time" timestamptz NOT NULL DEFAULT (now()),
  "status" varchar(20) NOT NULL
);

CREATE TABLE "Review" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "ride_history_id" uuid UNIQUE NOT NULL,
  "rating" int NOT NULL,
  "comment" text NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "Payment_History" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "ride_history_id" uuid NOT NULL,
  "payment_method_id" uuid NOT NULL,
  "amount" numeric(10,2) NOT NULL,
  "status" varchar(20) NOT NULL,
  "paid_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "Payment_Methods" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid NOT NULL,
  "type" varchar(20) NOT NULL,
  "provider" varchar(50) NOT NULL,
  "account_number" varchar(30) NOT NULL,
  "is_default" boolean NOT NULL
);

CREATE TABLE "Discount_History" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "payment_history_id" uuid NOT NULL,
  "discount_id" uuid NOT NULL,
  "discount_amount" numeric(10,2) NOT NULL,
  "applied_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "Discount" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "code" varchar(30) UNIQUE NOT NULL,
  "description" varchar(255) NOT NULL,
  "discount_type" varchar(10) NOT NULL,
  "value" numeric(10,2) NOT NULL,
  "valid_from" timestamptz NOT NULL DEFAULT (now()),
  "valid_to" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "Vehicles" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "rider_id" uuid NOT NULL,
  "vehicle_type_id" uuid NOT NULL,
  "license_plate" varchar(15) UNIQUE NOT NULL,
  "brand" varchar(50) NOT NULL,
  "model" varchar(50) NOT NULL,
  "color" varchar(30) NOT NULL,
  "year" int NOT NULL,
  "status" varchar(20) NOT NULL
);

CREATE TABLE "GovermentDocuments" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "rider_id" uuid NOT NULL,
  "document_type" varchar(3) NOT NULL,
  "document_number" varchar(30) NOT NULL,
  "file_url" varchar(255) NOT NULL,
  "verification_status" varchar(20) NOT NULL,
  "verified_at" timestamptz NOT NULL DEFAULT (now()),
  "expiry_date" date NOT NULL
);

CREATE TABLE "VehiclesTypes" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "name" varchar(50) NOT NULL,
  "description" varchar(255) NOT NULL,
  "base_fare" numeric(10,2) NOT NULL,
  "price_per_km" numeric(10,2) NOT NULL,
  "capacity" int NOT NULL
);

CREATE TABLE "DistanceToPrice" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "min_distance_km" numeric(6,2) NOT NULL,
  "max_distance_km" numeric(6,2) NOT NULL,
  "price_per_km" numeric(10,2) NOT NULL
);

CREATE TABLE "TimePriceMultiplier" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "name" varchar(50) NOT NULL,
  "start_time" time NOT NULL,
  "end_time" time NOT NULL,
  "multiplier" numeric(4,2) NOT NULL
);

CREATE TABLE "Audit_Log" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "table_name" varchar(50) NOT NULL,
  "record_id" uuid NOT NULL,
  "old_value" text NOT NULL,
  "new_value" text NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (now())
);

ALTER TABLE "users"
	ADD CONSTRAINT "fk_Rider_user_id_users"
	FOREIGN KEY ("id")
	REFERENCES "Rider" ("user_id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "GovermentDocuments"
	ADD CONSTRAINT "fk_GovermentDocuments_rider_id_Rider"
	FOREIGN KEY ("rider_id")
	REFERENCES "Rider" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "Vehicles"
	ADD CONSTRAINT "fk_Vehicles_rider_id_Rider"
	FOREIGN KEY ("rider_id")
	REFERENCES "Rider" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "Vehicles"
	ADD CONSTRAINT "fk_Vehicles_vehicle_type_id_VehiclesTypes"
	FOREIGN KEY ("vehicle_type_id")
	REFERENCES "VehiclesTypes" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "RideRequest"
	ADD CONSTRAINT "fk_RideRequest_user_id_users"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "RideHistory"
	ADD CONSTRAINT "fk_RideHistory_ride_request_id_RideRequest"
	FOREIGN KEY ("ride_request_id")
	REFERENCES "RideRequest" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "RideHistory"
	ADD CONSTRAINT "fk_RideHistory_user_id_users"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "RideHistory"
	ADD CONSTRAINT "fk_RideHistory_rider_id_Rider"
	FOREIGN KEY ("rider_id")
	REFERENCES "Rider" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "RideHistory"
	ADD CONSTRAINT "fk_RideHistory_vehicle_id_Vehicles"
	FOREIGN KEY ("vehicle_id")
	REFERENCES "Vehicles" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "Payment_Methods"
	ADD CONSTRAINT "fk_users_id_Payment_Methods"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "Payment_History"
	ADD CONSTRAINT "fk_Payment_History_ride_history_id_RideHistory"
	FOREIGN KEY ("ride_history_id")
	REFERENCES "RideHistory" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "Payment_History"
	ADD CONSTRAINT "fk_Payment_History_payment_method_id_Payment_Methods"
	FOREIGN KEY ("payment_method_id")
	REFERENCES "Payment_Methods" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "Review"
	ADD CONSTRAINT "fk_Review_ride_history_id_RideHistory"
	FOREIGN KEY ("ride_history_id")
	REFERENCES "RideHistory" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "Discount_History"
	ADD CONSTRAINT "fk_Discount_History_payment_history_id_Payment_History"
	FOREIGN KEY ("payment_history_id")
	REFERENCES "Payment_History" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "Discount_History"
	ADD CONSTRAINT "fk_Discount_History_discount_id_Discount"
	FOREIGN KEY ("discount_id")
	REFERENCES "Discount" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "Phone_user"
	ADD CONSTRAINT "fk_Phone_user_user_id_users"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;
