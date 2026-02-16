import http.server
import os
import socketserver

PORT = 8080


class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        name = os.getenv("NAME", "World")
        self.wfile.write(
            f"<html><body><h1>Hello, {name} from your new service!</h1></body></html>".encode(
                "utf8"
            )
        )


with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print("serving at port", PORT)
    httpd.serve_forever()
