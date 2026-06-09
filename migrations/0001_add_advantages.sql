CREATE TABLE "advantages" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"icon" text,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "property_advantages" (
	"id" serial PRIMARY KEY NOT NULL,
	"property_id" integer NOT NULL,
	"advantage_id" integer NOT NULL,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE INDEX "IDX_property_advantages_property_id" ON "property_advantages" USING btree ("property_id");
--> statement-breakpoint
CREATE INDEX "IDX_property_advantages_advantage_id" ON "property_advantages" USING btree ("advantage_id");
