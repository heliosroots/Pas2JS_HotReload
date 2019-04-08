unit hotreload_reloader;

{$mode objfpc}

interface

uses
  JS, Classes, SysUtils, Web;

var
  VPort: string = '8090';

implementation

initialization
  with TJSWebSocket.New('ws://localhost:' + VPort) do
  begin
    binaryType := 'arraybuffer';
    onmessage := function (Event: TEventListenerEvent): boolean
      begin
        if (Event.Properties['data'] = 'reload') then
        begin
          document.location.reload(True);
        end;
      end;

  end;
end.

