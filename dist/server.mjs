import {
  uploadImageRoute
} from "./chunk-QN6OBDCM.mjs";
import "./chunk-GLY7G5RS.mjs";
import "./chunk-5EVTLQ7U.mjs";
import "./chunk-7VYRV3HJ.mjs";

// src/server.ts
import { fastify } from "fastify";
import { fastifyCors } from "@fastify/cors";
import { fastifyMultipart } from "@fastify/multipart";
var server = fastify();
server.register(fastifyCors, {
  origin: "*"
});
server.register(fastifyMultipart);
server.register(uploadImageRoute);
server.listen({ port: 3333, host: "0.0.0.0" }).then(() => {
  console.log("HTTP server running!");
});
