-- SQL dump generated using DBML (dbml.dbdiagram.io)
-- Database: PostgreSQL
-- Generated at: 2026-09-13T07:54:10.191Z

-- เก็บข้อมูลพื้นฐานของผู้ใช้งานทุกคนในระบบ (ทั้ง user และ rider)
CREATE TABLE "users" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()), --ใช้ UUIDv7 เพื่อเลี่ยง ID ชนกัน
  "name" varchar(100) NOT NULL, -- ชื่อ-นามสกุล
  "email" varchar(150) UNIQUE NOT NULL, -- อีเมลห้ามล็อกอินซ้ำ
  "password_hash" varchar(255) NOT NULL, -- การเก็บค่า hash ของรหัสผ่าน
  "profile_image" varchar(255) NOT NULL, -- link รูปโปรไฟล์
  "created_at" timestamptz NOT NULL DEFAULT (now()),
  "update_at" timestamptz NOT NULL DEFAULT (now())
);

-- ตารางเก็บเบอร์โทร User แยกออกมาเพื่อรองรับได้หลายเบอร์
CREATE TABLE "Phone_user" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid NOT NULL,
  "phone_number" varchar(20) UNIQUE NOT NULL -- เบอร์ห้ามซ้ำกัน
);

-- เก็บข้อมูลเฉพาะ Rider
CREATE TABLE "Rider" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid UNIQUE NOT NULL,
  "status" varchar(20) NOT NULL, -- สถานะการทำงาน
  "total_rides" int NOT NULL, -- สถิติจำนวนรอบที่ให้บริการสำเร็จ
  "created_at" timestamptz NOT NULL DEFAULT (now()) -- วันที่สมัครเป็นคนขับ
);

-- ตารางคำขอเรียกรถ (สร้างเมื่อผู้ใช้กดค้นหาคนขับ)
CREATE TABLE "RideRequest" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid NOT NULL, -- userเรียก
  "vehicle_type_id" uuid NOT NULL, -- ประเภทรถที่ต้องการ
  "pickup_lat" numeric(9,6) NOT NULL, -- พิกัดรับ
  "pickup_lng" numeric(9,6) NOT NULL,
  "pickup_address" varchar(255) NOT NULL,
  "dropoff_lat" numeric(9,6) NOT NULL, -- พิกัดส่ง
  "dropoff_lng" numeric(9,6) NOT NULL,
  "dropoff_address" varchar(255),
  "status" varchar(20) NOT NULL, -- สถานะ (Searching , Accepted, Cancelled)
  "requested_at" timestamptz
);

-- ตารางประวัติการเดินทาง (เมื่อคนขับรับงานแล้ว)
CREATE TABLE "RideHistory" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "ride_request_id" uuid  NOT NULL,
  "user_id" uuid  NOT NULL,
  "rider_id" uuid NOT NULL,
  "vehicle_id" uuid NOT NULL,
  "distance_km" numeric(6,2) NOT NULL,
  "duration_min" int NOT NULL,
  "base_price" numeric(10,2) NOT NULL,, -- ราคาก่อนหักส่วนลด
  "final_price" numeric(10,2) NOT NULL,, -- ราคาที่ต้องจ่ายจริง
  "start_time" timestamptz  NOT NULL DEFAULT (now()),
  "end_time" timestamptz,
  "status" varchar(20)  NOT NULL-- Completed, Cancelled
);

-- ตารางรีวิวและให้คะแนนหลังจบการเดินทาง
CREATE TABLE "Review" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "ride_history_id" uuid UNIQUE NOT NULL,
  "rating" int NOT NULL, -- คะแนน (1-5)
  "comment" text,
  "created_at" timestamptz NOT NULL DEFAULT (now())
);

-- ตารางประวัติการชำระเงินของการเดินทางแต่ละรอบ
CREATE TABLE "Payment_History" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "ride_history_id" uuid NOT NULL,
  "payment_method_id" uuid NOT NULL, -- จ่ายด้วยช่องทางไหน
  "amount" numeric(10,2) NOT NULL,
  "status" varchar(20) NOT NULL,-- สถานะการตัดเงิน: 'SUCCESS', 'FAILED', 'REFUNDED'
  "paid_at" timestamptz
);

-- ตารางช่องทางการชำระเงินของผู้ใช้ (บัตรเครดิต, ธนาคาร)
CREATE TABLE "Payment_Methods" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "user_id" uuid NOT NULL,
  "type" varchar(20) NOT NULL, -- ประเภท: 'CREDIT_CARD', 'CASH'
  "provider" varchar(50) NOT NULL, -- ผู้ให้บริการ: 'VISA', 'MasterCard',
  "account_number" varchar(30) NOT NULL, -- เลขที่บัญชี/บัตร
  "is_default" boolean NOT NULL -- ตั้งเป็นช่องทางชำระเงินเริ่มต้นหรือไม่ (True/False)
);

-- ตารางบันทึกประวัติการใช้งานโค้ดส่วนลด
CREATE TABLE "Discount_History" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "payment_history_id" uuid NOT NULL, -- ลดในการจ่ายเงินบิลไหน
  "discount_id" uuid NOT NULL, -- ใช้โค้ดส่วนลดตัวไหน
  "discount_amount" numeric(10,2) NOT NULL, -- จำนวนเงินที่ประหยัดได้ (บาท)
  "applied_at" timestamptz NOT NULL DEFAULT (now()) -- เวลาที่กดใช้โค้ด
);

-- ตารางโค้ดส่วนลด (Promo Codes)
CREATE TABLE "Discount" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "code" varchar(30) UNIQUE NOT NULL,
  "description" varchar(255) NOT NULL,
  "discount_type" varchar(10) NOT NULL, -- ประเภท: 'PERCENT' (ลดเป็น %), 'FIXED' (ลดเป็นบาท)
  "value" numeric(10,2) NOT NULL, -- มูลค่าการลด
  "valid_from" timestamptz NOT NULL DEFAULT (now()), -- วันที่เริ่มใช้โค้ดได้
  "valid_to" timestamptz  NOT NULL DEFAULT (now()), -- วันที่โค้ดหมดอายุ
);

-- ตารางเก็บข้อมูลรถยนต์/มอเตอร์ไซค์ ของคนขับแต่ละคน
CREATE TABLE "Vehicles" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "rider_id" uuid NOT NULL, -- FK รถคันนี้ใครเป็นคนขับ
  "vehicle_type_id" uuid NOT NULL,  -- FK จัดอยู่ในรถประเภทไหน
  "license_plate" varchar(15) UNIQUE NOT NULL, -- ทะเบียนรถ (ต้องไม่ซ้ำในระบบ เพื่อป้องกันการสวมรอย)
  "brand" varchar(50) NOT NULL,
  "model" varchar(50) NOT NULL,
  "color" varchar(30) NOT NULL,
  "year" int NOT NULL,
  "status" varchar(20) NOT NULL -- สถานะรถ: 'ACTIVE'
);

-- ตารางเก็บข้อมูลอกสารสำคัญของคนขับสำหรับตรวจสอบความถูกต้องตามกฎหมาย เช่น ใบขับขี่สาธารณะ
CREATE TABLE "GovermentDocuments" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "rider_id" uuid NOT NULL, -- ชี้ว่าเอกสารนี้เป็นของคนขับคนไหน
  "document_type" varchar(3) NOT NULL, -- รหัสประเภทเอกสาร เช่น 'IDC' (บัตรปชช)
  "document_number" varchar(30) NOT NULL,
  "file_url" varchar(255) NOT NULL,
  "verification_status" varchar(20) NOT NULL, -- สถานะการตรวจสอบโดย Admin: 'PENDING', 'APPROVED', 'REJECTED'
  "verified_at" timestamptz NOT NULL, -- วันเวลาที่ Admin อนุมัติ
  "expiry_date" date NOT NULL -- วันหมดอายุของเอกสาร
);

-- ตารางเก็บข้อมูลประเภทของยานพาหนะที่ระบบรองรับใช้สำหรับการแบ่งเกรดรถ
CREATE TABLE "VehiclesTypes" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "name" varchar(50) NOT NULL, -- ชื่อประเภท เช่น 'Economy Car', 'Premium SUV', 'Motorcycle'
  "description" varchar(255) NOT NULL, -- คำอธิบายให้ผู้โดยสารเห็น
  "base_fare" numeric(10,2) NOT NULL, -- ราคาเริ่มต้น (ค่าเรียก) *ใช้ numeric เพื่อป้องกันปัญหาตัวเลขทศนิยมคลาดเคลื่อนของ float
  "price_per_km" numeric(10,2) NOT NULL,
  "capacity" int NOT NULL -- จำนวนผู้โดยสารสูงสุดที่รับได้
);

-- ตารางเก็บข้อมูลโครงสร้างราคาแบบขั้นบันได
CREATE TABLE "DistanceToPrice" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "min_distance_km" numeric(6,2) NOT NULL, -- ระยะทางเริ่มต้นของขั้นนี้
  "max_distance_km" numeric(6,2) NOT NULL, -- ระยะทางสิ้นสุดของขั้นนี้
  "price_per_km" numeric(10,2) NOT NULL -- อัตราค่าบริการในขั้นระยะทางนี้
);

-- ตารางเก็บข้อมูลตัวคูณราคาตามช่วงเวลา 
-- ระบบจะดึงค่านี้ไปคูณราคาปกติเมื่อมีการเรียกรถในช่วงเวลาที่กำหนด
CREATE TABLE "TimePriceMultiplier" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "name" varchar(50) NOT NULL, -- ชื่อช่วงเวลา เช่น 'Morning Rush', 'Midnight Charge
  "start_time" time NOT NULL,
  "end_time" time NOT NULL,
  "multiplier" numeric(4,2) NOT NULL -- ตัวคูณราคา
);

-- ตารางเก็บข้อมูลบันทึกร่องรอยการแก้ไขข้อมูล 
-- สำคัญมากสำหรับระบบที่เกี่ยวกับเงินและการเดินทาง เพื่อป้องกันการทุจริต หรือตามสืบเคสปัญหา
CREATE TABLE "Audit_Log" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT (UUIDV7()),
  "table_name" varchar(50) NOT NULL, -- ชื่อตารางที่มีการแก้ไข
  "record_id" uuid NOT NULL, -- ID ของแถวที่ถูกแก้ไข
  "old_value" text NOT NULL,
  "new_value" text NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (now()) -- เวลาที่มีการแก้ไข
);

CREATE UNIQUE INDEX "GovermentDocuments_unique_0" ON "GovermentDocuments" ("document_type", "document_number");

-- ตาราง rider เชื่อมกับตาราง users
-- FK: "user_id" (ในตาราง Rider) อ้างอิงไปยัง PK: "id" (ในตาราง users)
-- Relationship: 1 to 1 (ผู้ใช้งาน 1 คน เป็นคนขับได้ 1 บัญชี)
ALTER TABLE "users"
	ADD CONSTRAINT "fk_Rider_user_id_users"
	FOREIGN KEY ("id")
	REFERENCES "Rider" ("user_id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง GovermentDocuments เชื่อมกับตาราง Rider
-- FK: "rider_id" (ในตารางGovermentDocuments ) อ้างอิงไปยัง PK: "id" (ในตาราง Rider)
-- Relationship: 1 to many (คนขับ 1 คน มีเอกสารสำคัญได้หลายใบ)
ALTER TABLE "GovermentDocuments"
	ADD CONSTRAINT "fk_GovermentDocuments_rider_id_Rider"
	FOREIGN KEY ("rider_id")
	REFERENCES "Rider" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง Vehicles เชื่อมกับตาราง Rider
-- FK: "rider_id" (ในตาราง Vehicles ) อ้างอิงไปยัง PK: "id" (ในตาราง Rider)
-- Relationship: 1 to many (คนขับ 1 คน ลงทะเบียนรถได้หลายคัน))
ALTER TABLE "Vehicles"
	ADD CONSTRAINT "fk_Vehicles_rider_id_Rider"
	FOREIGN KEY ("rider_id")
	REFERENCES "Rider" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง Vehicles เชื่อมกับตาราง VehiclesTypes
-- FK: "vehicle_type_id" (ในตาราง Vehicles ) อ้างอิงไปยัง PK: "id" (ในตาราง VehiclesTypes)
-- Relationship: 1 to many (ประเภทรถ 1 ประเภท มีรถอยู่ในหมวดหมู่นี้ได้หลายคัน)
ALTER TABLE "Vehicles"
	ADD CONSTRAINT "fk_Vehicles_vehicle_type_id_VehiclesTypes"
	FOREIGN KEY ("vehicle_type_id")
	REFERENCES "VehiclesTypes" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;


-- ตาราง RideRequest เชื่อมกับตาราง users
-- FK: "user_id" (ในตาราง RideRequest) อ้างอิงไปยัง PK: "id" (ในตาราง users)
-- Relationship: 1 to many (ผู้ใช้งาน 1 คน สร้างคำเรียกรถได้หลายครั้ง)
ALTER TABLE "RideRequest"
	ADD CONSTRAINT "fk_RideRequest_user_id_users"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง RideHistory เชื่อมกับตาราง RideRequest
-- FK: "ride_request_id" (ในตาราง RideHistory) อ้างอิงไปยัง PK: "id" (ในตาราง RideRequest)
-- Relationship: 1 to 1 (คำเรียกรถ 1 ครั้ง ถูกบันทึกเป็นประวัติการเดินทาง 1 รายการ)
ALTER TABLE "RideHistory"
	ADD CONSTRAINT "fk_RideHistory_ride_request_id_RideRequest"
	FOREIGN KEY ("ride_request_id")
	REFERENCES "RideRequest" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง RideHistory เชื่อมกับตาราง users
-- FK: "user_id" (ในตาราง RideHistory) อ้างอิงไปยัง PK: "id" (ในตาราง users)
-- Relationship: 1 to many (ผู้ใช้งาน 1 คน มีประวัติการเดินทางได้หลายครั้ง)
ALTER TABLE "RideHistory"
	ADD CONSTRAINT "fk_RideHistory_user_id_users"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง RideHistory เชื่อมกับตาราง Rider
-- FK: "rider_id" (ในตาราง RideHistory) อ้างอิงไปยัง PK: "id" (ในตาราง Rider)
-- Relationship: 1 to many (คนขับ 1 คน มีประวัติการให้บริการได้หลายครั้ง)
ALTER TABLE "RideHistory"
	ADD CONSTRAINT "fk_RideHistory_rider_id_Rider"
	FOREIGN KEY ("rider_id")
	REFERENCES "Rider" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง RideHistory เชื่อมกับตาราง Vehicles
-- FK: "vehicle_id" (ในตาราง RideHistory) อ้างอิงไปยัง PK: "id" (ในตาราง Vehicles)
-- Relationship: 1 to many (รถ 1 คัน ถูกใช้ในประวัติการเดินทางได้หลายครั้ง)
ALTER TABLE "RideHistory"
	ADD CONSTRAINT "fk_RideHistory_vehicle_id_Vehicles"
	FOREIGN KEY ("vehicle_id")
	REFERENCES "Vehicles" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง Payment Methods เชื่อมกับตาราง users
-- FK: "user_id" (ในตาราง Payment Methods) อ้างอิงไปยัง PK: "id" (ในตาราง users)
-- Relationship: 1 to many (ผู้ใช้งาน 1 คน มีช่องทางชำระเงินได้หลายวิธี)
ALTER TABLE "Payment_Methods"
	ADD CONSTRAINT "fk_users_id_Payment_Methods"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง Payment History เชื่อมกับตาราง RideHistory
-- FK: "ride_history_id" (ในตาราง Payment History) อ้างอิงไปยัง PK: "id" (ในตาราง RideHistory)
-- Relationship: 1 to 1 (ประวัติการเดินทาง 1 ครั้ง มีประวัติการชำระเงิน 1 รายการ)
ALTER TABLE "Payment_History"
	ADD CONSTRAINT "fk_Payment_History_ride_history_id_RideHistory"
	FOREIGN KEY ("ride_history_id")
	REFERENCES "RideHistory" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง Payment History เชื่อมกับตาราง Payment Methods
-- FK: "payment_method_id" (ในตาราง Payment History) อ้างอิงไปยัง PK: "id" (ในตาราง Payment Methods)
-- Relationship: 1 to many (ช่องทางชำระเงิน 1 วิธี ถูกใช้ทำรายการชำระเงินได้หลายครั้ง)
ALTER TABLE "Payment_History"
	ADD CONSTRAINT "fk_Payment_History_payment_method_id_Payment_Methods"
	FOREIGN KEY ("payment_method_id")
	REFERENCES "Payment_Methods" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง Review เชื่อมกับตาราง Ride History
-- FK: "ride_history_id" (ในตาราง Review) อ้างอิงไปยัง PK: "id" (ในตาราง Ride History)
-- Relationship: 1 to 1 (การชำระเงิน 1 รายการ มีรีวิวได้ 1 ครั้ง)
ALTER TABLE "Review"
	ADD CONSTRAINT "fk_Review_ride_history_id_RideHistory"
	FOREIGN KEY ("ride_history_id")
	REFERENCES "RideHistory" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง Discount History เชื่อมกับตาราง Payment History
-- FK: "payment_history_id" (ในตาราง Discount History) อ้างอิงไปยัง PK: "id" (ในตาราง Payment History)
-- Relationship: 1 to many (การชำระเงิน 1 รายการ อาจมีการบันทึกประวัติการใช้ส่วนลดได้หลายรายการ หากใช้ร่วมกันได้)
ALTER TABLE "Discount_History"
	ADD CONSTRAINT "fk_Discount_History_payment_history_id_Payment_History"
	FOREIGN KEY ("payment_history_id")
	REFERENCES "Payment_History" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง Discount History เชื่อมกับตาราง Discount
-- FK: "discount_id" (ในตาราง Discount History) อ้างอิงไปยัง PK: "id" (ในตาราง Discount)
-- Relationship: 1 to many (รหัสส่วนลด 1 โค้ด ถูกบันทึกลงในประวัติการใช้งานได้หลายครั้ง)
ALTER TABLE "Discount_History"
	ADD CONSTRAINT "fk_Discount_History_discount_id_Discount"
	FOREIGN KEY ("discount_id")
	REFERENCES "Discount" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;

-- ตาราง Phone_user เชื่อมกับตาราง users
-- FK: "user_id" (ในตาราง Phone_user) อ้างอิงไปยัง PK: "id" (ในตาราง users)
-- Relationship: 1 to many (ผู้ใช้งาน 1 คน ลงทะเบียนเบอร์โทรศัพท์ได้หลายเบอร์)
ALTER TABLE "Phone_user"
	ADD CONSTRAINT "fk_Phone_user_user_id_users"
	FOREIGN KEY ("user_id")
	REFERENCES "users" ("id")
	ON DELETE RESTRICT
	ON UPDATE NO ACTION;
