// import BackendClientScript from "@myriaddreamin/tylant-backend-client";

import { kEnableBackend, kEnableClick } from "$consts";
import Stub from "./Stub.astro";

export const BackendClientScript = kEnableBackend
  ? (await import("@myriaddreamin/tylant-backend-client")).default
  : Stub;

export const PostClick = kEnableClick
  ? (await import("@myriaddreamin/tylant-click")).PostClick
  : Stub;
