{$IFNDEF VER130}

//  Proc/Fun     : procedure IncludeTrailingBackSlash
//
//  Valor retorno: string
//  Parametros   : S: string
//
//  Comentarios  : Función de compilación condicional que sustituye a la
//                 existente en la VCL a partir de Delphi 5.
//                 Se introduce por compatibilidad.
//
function IncludeTrailingBackslash(const S: string): string;
begin
   if S[length(S)] = '\' then 
      result := S 
   else 
      result := S + '\';
end;


//  Proc/Fun     : procedure ExcludeTrailingBackSlash
//
//  Valor retorno: string
//  Parametros   : S: string
//
//  Comentarios  : Función de compilación condicional que sustituye a la
//                 existente en la VCL a partir de Delphi 5.
//                 Se introduce por compatibilidad.
//
function ExcludeTrailingBackslash(const S: string): string;
var
   l: integer;
begin
   l := length(S);
   result := S;

   if S[l] = '\' then 
      SetLength(result, l-1);
end;

{$ENDIF}
