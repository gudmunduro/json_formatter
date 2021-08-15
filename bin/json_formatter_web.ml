open Core
open Json_parser.Encoder
open Json_parser.Decoder
open Opium

let format_json req =
  let content = Body.to_stream req.Request.body in
  let formatted = Lwt_stream.map (fun c -> decode_json c |> encode_json ~formatted:true) content in
  Response.make ~body:(Body.of_stream formatted) ~headers: (Httpaf.Headers.of_list [ "Content-Type", "text/plain" ]) () |> Lwt.return

let minify_json req =
  let content = Body.to_stream req.Request.body in
  let formatted = Lwt_stream.map (fun c -> decode_json c |> encode_json ~formatted:false) content in
  Response.make ~body:(Body.of_stream formatted) ~headers: (Httpaf.Headers.of_list [ "Content-Type", "text/plain" ]) () |> Lwt.return

let web_ui _ =
  let lines = Lwt_io.lines_of_file "./html/index.html" in
  Response.make ~body:(Body.of_stream lines) () |> Lwt.return

let () =
  App.empty
  |> App.get "/" web_ui
  |> App.post "/api/json/formatted" format_json
  |> App.post "/api/json/minified" minify_json
  |> App.middleware (Middleware.static_unix ~local_path:"./static/js" ?uri_prefix: (Some "/js") ())
  |> App.middleware (Middleware.static_unix ~local_path:"./static/css" ?uri_prefix: (Some "/css") ())
  |> App.port 8070
  |> App.run_command