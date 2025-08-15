# app.py
import os
import signal
import logging
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logging.basicConfig(level=LOG_LEVEL, format="%(asctime)s %(levelname)s %(message)s")

PORT = int(os.getenv("PORT", "8000"))
HOST = "0.0.0.0"

class Handler(BaseHTTPRequestHandler):
    def _send(self, code=200, body="ok", content_type="text/plain"):
        body_bytes = body.encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", content_type + "; charset=utf-8")
        self.send_header("Content-Length", str(len(body_bytes)))
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body_bytes)

    def do_GET(self):  # noqa: N802
        if self.path in ("/health", "/healthz", "/livez"):
            self._send(200, "ok")
        elif self.path in ("/", "/ping"):
            self._send(200, "orchestrator up")
        else:
            self._send(404, "not found")

    def do_HEAD(self):  # noqa: N802
        if self.path in ("/health", "/healthz", "/livez"):
            self._send(200, "")
        elif self.path in ("/", "/ping"):
            self._send(200, "")
        else:
            self._send(404, "")

    # 安静一点，避免每次请求都打印到控制台
    def log_message(self, fmt, *args):
        logging.info("%s - - " + fmt, self.address_string(), *args)

def main():
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    logging.info(f"starting http server on http://{HOST}:{PORT}")

    def handle_sigterm(signum, frame):
        logging.info("received SIGTERM, shutting down...")
        server.shutdown()

    signal.signal(signal.SIGTERM, handle_sigterm)

    try:
        server.serve_forever(poll_interval=0.5)
    except KeyboardInterrupt:
        logging.info("received SIGINT, shutting down...")
    finally:
        server.server_close()
        logging.info("server stopped")

if __name__ == "__main__":
    main()

