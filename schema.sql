-- SQL dump generated using DBML (dbml.dbdiagram.io)
-- Database: PostgreSQL
-- Generated at: 2026-10-09T06:47:04.328Z

CREATE TYPE "RiderStatus" AS ENUM (
  'ACTIVE',
  'INACTIVE',
  'SUSPENDED'
);

CREATE TYPE "RideStatus" AS ENUM (
  'REQUESTED',
  'ACCEPTED',
  'IN_PROGRESS',
  'COMPLETED',
  'CANCELLED'
);

CREATE TYPE "RideHistoryStatus" AS ENUM (
  'COMPLETED',
  'CANCELLED'
);

CREATE TYPE "PaymentStatus" AS ENUM (
  'PAID',
  'PENDING',
  'FAILED'
);

CREATE TYPE "DiscountType" AS ENUM (
  'PERCENTAGE',
  'FIXED'
);

CREATE TYPE "VehicleStatus" AS ENUM (
  'ACTIVE',
  'INACTIVE',
  'MAINTENANCE'
);

CREATE TYPE "DocumentType" AS ENUM (
  'ID',
  'DL'
);

CREATE TYPE "VerificationStatus" AS ENUM (
  'VERIFIED',
  'PENDING',
  'REJECTED'
);

CREATE TYPE "AuditAction" AS ENUM (
  'CREATE',
  'UPDATE',
  'DELETE'
);

CREATE TABLE "Users" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "name" varchar(100) NOT NULL,
  "email" varchar(150) UNIQUE NOT NULL,
  "password_hash" varchar(255) NOT NULL,
  "profile_image" varchar(255),
  "created_at" timestamptz NOT NULL DEFAULT (now()),
  "updated_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "UserPhones" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid NOT NULL,
  "phone_number" varchar(20) UNIQUE NOT NULL
);

CREATE TABLE "Riders" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid UNIQUE NOT NULL,
  "status" "RiderStatus" NOT NULL,
  "total_rides" int NOT NULL CHECK (total_rides >= 0) DEFAULT 0,
  "created_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "RideRequests" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid NOT NULL,
  "rider_id" uuid,
  "vehicle_type_id" uuid NOT NULL,
  "pickup_lat" numeric(9,6) NOT NULL CHECK (pickup_lat >= -90 AND pickup_lat <= 90),
  "pickup_lng" numeric(9,6) NOT NULL CHECK (pickup_lng >= -180 AND pickup_lng <= 180),
  "pickup_address" varchar(255) NOT NULL,
  "dropoff_lat" numeric(9,6) NOT NULL CHECK (dropoff_lat >= -90 AND dropoff_lat <= 90),
  "dropoff_lng" numeric(9,6) NOT NULL CHECK (dropoff_lng >= -180 AND dropoff_lng <= 180),
  "dropoff_address" varchar(255) NOT NULL,
  "status" "RideStatus" NOT NULL DEFAULT (REQUESTED),
  "requested_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "RideHistories" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "ride_request_id" uuid NOT NULL,
  "user_id" uuid NOT NULL,
  "rider_id" uuid NOT NULL,
  "vehicle_id" uuid NOT NULL,
  "distance_km" numeric(6,2) NOT NULL CHECK (distance_km >= 0),
  "duration_min" int NOT NULL CHECK (duration_min >= 0),
  "base_price" numeric(10,2) NOT NULL CHECK (base_price >= 0),
  "final_price" numeric(10,2) NOT NULL CHECK (final_price >= 0),
  "start_time" timestamptz NOT NULL DEFAULT (now()),
  "end_time" timestamptz,
  "status" "RideHistoryStatus" NOT NULL
);

CREATE TABLE "Reviews" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "ride_history_id" uuid UNIQUE NOT NULL,
  "rating" int NOT NULL CHECK (rating >= 1 AND rating <= 5),
  "comment" varchar(255),
  "created_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "PaymentHistories" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "ride_history_id" uuid NOT NULL,
  "payment_method_id" uuid NOT NULL,
  "amount" numeric(10,2) NOT NULL CHECK (amount > 0),
  "status" "PaymentStatus" NOT NULL DEFAULT (PENDING),
  "paid_at" timestamptz
);

CREATE TABLE "PaymentMethods" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid NOT NULL,
  "type" varchar(20) NOT NULL,
  "provider" varchar(50) NOT NULL,
  "account_number" varchar(30) NOT NULL,
  "is_default" boolean NOT NULL DEFAULT false
);

CREATE TABLE "DiscountHistories" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "payment_history_id" uuid NOT NULL,
  "discount_id" uuid NOT NULL,
  "discount_amount" numeric(10,2) NOT NULL CHECK (discount_amount > 0),
  "applied_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "Discounts" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "code" varchar(30) UNIQUE NOT NULL,
  "description" varchar(255) NOT NULL,
  "discount_type" "DiscountType" NOT NULL,
  "value" numeric(10,2) NOT NULL CHECK (value > 0),
  "valid_from" timestamptz NOT NULL DEFAULT (now()),
  "valid_to" timestamptz NOT NULL,
  CONSTRAINT "valid_from_must_be_less_than_valid_to" CHECK (valid_from < valid_to)
);

CREATE TABLE "Vehicles" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "rider_id" uuid NOT NULL,
  "vehicle_type_id" uuid NOT NULL,
  "license_plate" varchar(15) UNIQUE NOT NULL,
  "brand" varchar(50) NOT NULL,
  "model" varchar(50) NOT NULL,
  "color" varchar(30) NOT NULL,
  "year" int NOT NULL CHECK (year >= 1900 AND year <= 2100),
  "status" "VehicleStatus" NOT NULL
);

CREATE TABLE "GovernmentDocuments" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "rider_id" uuid NOT NULL,
  "document_type" "DocumentType" NOT NULL,
  "document_number" varchar(30) NOT NULL,
  "file_url" varchar(255) NOT NULL,
  "verification_status" "VerificationStatus" NOT NULL DEFAULT (PENDING),
  "verified_at" timestamptz,
  "expiry_date" date NOT NULL
);

CREATE TABLE "VehicleTypes" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "name" varchar(50) UNIQUE NOT NULL,
  "description" varchar(255) NOT NULL,
  "base_fare" numeric(10,2) NOT NULL CHECK (base_fare >= 0),
  "price_per_km" numeric(10,2) NOT NULL CHECK (price_per_km >= 0),
  "capacity" int NOT NULL CHECK (capacity > 0)
);

CREATE TABLE "DistanceToPrices" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "min_distance_km" numeric(6,2) NOT NULL,
  "max_distance_km" numeric(6,2) NOT NULL,
  "price_per_km" numeric(10,2) NOT NULL CHECK (price_per_km >= 0),
  CONSTRAINT "min_must_be_less_than_max" CHECK (min_distance_km < max_distance_km)
);

CREATE TABLE "TimePriceMultipliers" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "name" varchar(50) NOT NULL,
  "start_time" time NOT NULL,
  "end_time" time NOT NULL,
  "multiplier" numeric(4,2) NOT NULL CHECK (multiplier > 0),
  CONSTRAINT "start_must_be_less_than_end" CHECK (start_time < end_time)
);

CREATE TABLE "AuditLogs" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "table_name" varchar(50) NOT NULL,
  "record_id" uuid NOT NULL,
  "action" "AuditAction" NOT NULL,
  "changed_by" uuid,
  "old_value" text,
  "new_value" text,
  "created_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE UNIQUE INDEX ON "GovernmentDocuments" ("document_type", "document_number");

ALTER TABLE "Riders"
	ADD CONSTRAINT "fk_Riders_user_id_Users"
	FOREIGN KEY ("user_id")
	REFERENCES "Users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "UserPhones"
	ADD CONSTRAINT "fk_UserPhones_user_id_Users"
	FOREIGN KEY ("user_id")
	REFERENCES "Users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "GovernmentDocuments"
	ADD CONSTRAINT "fk_GovernmentDocuments_rider_id_Riders"
	FOREIGN KEY ("rider_id")
	REFERENCES "Riders" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "Vehicles"
	ADD CONSTRAINT "fk_Vehicles_rider_id_Riders"
	FOREIGN KEY ("rider_id")
	REFERENCES "Riders" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "Vehicles"
	ADD CONSTRAINT "fk_Vehicles_vehicle_type_id_VehicleTypes"
	FOREIGN KEY ("vehicle_type_id")
	REFERENCES "VehicleTypes" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "RideRequests"
	ADD CONSTRAINT "fk_RideRequests_user_id_Users"
	FOREIGN KEY ("user_id")
	REFERENCES "Users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "RideRequests"
	ADD CONSTRAINT "fk_RideRequests_rider_id_Riders"
	FOREIGN KEY ("rider_id")
	REFERENCES "Riders" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "RideRequests"
	ADD CONSTRAINT "fk_RideRequests_vehicle_type_id_VehicleTypes"
	FOREIGN KEY ("vehicle_type_id")
	REFERENCES "VehicleTypes" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "RideHistories"
	ADD CONSTRAINT "fk_RideHistories_ride_request_id_RideRequests"
	FOREIGN KEY ("ride_request_id")
	REFERENCES "RideRequests" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "RideHistories"
	ADD CONSTRAINT "fk_RideHistories_user_id_Users"
	FOREIGN KEY ("user_id")
	REFERENCES "Users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "RideHistories"
	ADD CONSTRAINT "fk_RideHistories_rider_id_Riders"
	FOREIGN KEY ("rider_id")
	REFERENCES "Riders" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "RideHistories"
	ADD CONSTRAINT "fk_RideHistories_vehicle_id_Vehicles"
	FOREIGN KEY ("vehicle_id")
	REFERENCES "Vehicles" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "PaymentMethods"
	ADD CONSTRAINT "fk_PaymentMethods_user_id_Users"
	FOREIGN KEY ("user_id")
	REFERENCES "Users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "PaymentHistories"
	ADD CONSTRAINT "fk_PaymentHistories_ride_history_id_RideHistories"
	FOREIGN KEY ("ride_history_id")
	REFERENCES "RideHistories" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "PaymentHistories"
	ADD CONSTRAINT "fk_PaymentHistories_payment_method_id_PaymentMethods"
	FOREIGN KEY ("payment_method_id")
	REFERENCES "PaymentMethods" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "Reviews"
	ADD CONSTRAINT "fk_Reviews_ride_history_id_RideHistories"
	FOREIGN KEY ("ride_history_id")
	REFERENCES "RideHistories" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "DiscountHistories"
	ADD CONSTRAINT "fk_DiscountHistories_payment_history_id_PaymentHistories"
	FOREIGN KEY ("payment_history_id")
	REFERENCES "PaymentHistories" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "DiscountHistories"
	ADD CONSTRAINT "fk_DiscountHistories_discount_id_Discounts"
	FOREIGN KEY ("discount_id")
	REFERENCES "Discounts" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

ALTER TABLE "AuditLogs"
	ADD CONSTRAINT "fk_AuditLogs_changed_by_Users"
	FOREIGN KEY ("changed_by")
	REFERENCES "Users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;
