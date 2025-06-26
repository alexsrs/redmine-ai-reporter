import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";

export async function testFunction(
  _request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  context.log("Test function called");

  return {
    status: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
    jsonBody: {
      message: "Hello from Azure Functions!",
      timestamp: new Date().toISOString(),
    },
  };
}

app.http("test", {
  methods: ["GET", "POST"],
  authLevel: "anonymous",
  handler: testFunction,
});
