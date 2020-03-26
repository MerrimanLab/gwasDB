--- gwas_etl


CREATE TABLE IF NOT EXISTS "b37"(
  "kgp_id" TEXT PRIMARY KEY,
  "chr" integer NOT NULL, --- plink codings ---
  "pos" INTEGER NOT NULL,
  "ref" TEXT,
  "alt" TEXT
);


CREATE TABLE IF NOT EXISTS "marker"(
  "kgp_id" TEXT NOT NULL,
  "marker_name" TEXT NOT NULL,
  UNIQUE(kgp_id, marker_name),
  FOREIGN KEY ("kgp_id") REFERENCES b37("kgp_id")
);




CREATE TABLE IF NOT EXISTS "study"(
  "id" SERIAL,
  "name" TEXT NOT NULL,
  "ancestry" TEXT NOT NULL,
  "model_formula" TEXT,
  "gwas_date" DATE,
  "n" INTEGER,
  "n_case" INTEGER,
  "n_control" INTEGER,
  "imputed" BOOLEAN,
  "impute_ref_panel" TEXT,
  "summary_only" BOOLEAN,
  "citation" TEXT,
  "url" TEXT,
  "xsan_path" TEXT,
  "comment" TEXT,
  UNIQUE(id)
);


CREATE TABLE IF NOT EXISTS "gwas"(
  "kgp_id" TEXT NOT NULL,
  "study_id" INTEGER NOT NULL,
  "a1" TEXT NOT NULL,
  "a2" TEXT,
  "stat" FLOAT NOT NULL,
  "se" FLOAT,
  "neg_log10_p" FLOAT,
  "imputed_tf" BOOLEAN,
  "impute_score" FLOAT,
  "maf_all" FLOAT,
  "maf_aff" FLOAT,
  "maf_unaff" FLOAT,
  "geno_all" TEXT,
  "geno_aff" TEXT,
  "geno_unaff" TEXT,
  "hwe_p_all" FLOAT,
  "hwe_p_aff" FLOAT,
  "hwe_p_unaff" FLOAT,
  PRIMARY KEY (kgp_id, study_id),
  FOREIGN KEY ("kgp_id") REFERENCES b37("kgp_id"),
  FOREIGN KEY ("study_id") REFERENCES study("id")
);




CREATE TABLE IF NOT EXISTS "no_gwas_result"(
  "kgp_id" TEXT NOT NULL,
  "study_id" INTEGER NOT NULL,
  PRIMARY KEY (kgp_id,study_id),
  FOREIGN KEY ("kgp_id") REFERENCES b37("kgp_id"),
  FOREIGN KEY ("study_id") REFERENCES study("id")
);
