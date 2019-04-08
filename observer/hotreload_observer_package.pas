{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit hotreload_observer_package;

{$warn 5023 off : no warning about unused units}
interface

uses
  hotreload_observer, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('hotreload_observer', @hotreload_observer.Register);
end;

initialization
  RegisterPackage('hotreload_observer_package', @Register);
end.
