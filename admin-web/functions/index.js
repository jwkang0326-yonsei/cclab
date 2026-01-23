import { onRequest } from "firebase-functions/v2/https";
import express from "express";
import compression from "compression";
import morgan from "morgan";
import { createRequestHandler } from "@react-router/express";

const app = express();

app.use(compression());
app.disable("x-powered-by");
app.use(morgan("tiny"));

// React Router 빌드 결과물 경로 (배포 시 functions 폴더 내부로 복사됨)
const BUILD_PATH = "./build/server/index.js";

// React Router 요청 핸들러 연결
app.all(
  "*",
  createRequestHandler({
    build: () => import(BUILD_PATH),
  })
);

// Firebase Functions로 내보내기 (이름: server)
export const server = onRequest({ region: "asia-northeast3", timeoutSeconds: 60 }, app);