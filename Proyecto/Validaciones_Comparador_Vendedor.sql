#Función para validar el nombre
DELIMITER \\
CREATE FUNCTION validar_nombre(nombre varchar(250))
RETURNS bool
DETERMINISTIC
begin
declare valido bool;
declare formato bool;#valida usando una expresión regular
select nombre regexp "^[a-zA-ZñÑáÁéÉíÍóÓúÚ\s]{2,64}$" into formato;
if formato=1 then set valido=1;
else set valido=0;
end if;
return valido;
end;\\
#Ejemplo
/*
select validar_nombre("Jose");
select validar_nombre("Jonás");
select validar_nombre("Ñato1");*/
#funcion para validar el celular
delimiter \\
CREATE FUNCTION validar_telefono(telefono varchar(250))
RETURNS bool
DETERMINISTIC
begin
declare valido bool;
#valida usando una expresión regular
select telefono regexp "^09{1}[0-9]{8}$" into valido;
return valido;
end;\\
#drop function validar_telefono;
#select validar_telefono("0984418872");
#El problema es que al poner un ingreso de varchar10, al ingresar más de eso ya no valida y pone
#como si fuera verdadero. Eso ya no se puede restringir, por eso le puse de mas
delimiter \\
CREATE FUNCTION validar_cedula(cedula varchar(250))
RETURNS bool
DETERMINISTIC
begin
declare valido bool;
#valida usando una expresión regular
select cedula regexp "^(0[1-9]|1[0-9]|2[0-4]){1}[0-9]{8}$" into valido;
return valido;
end;\\
#Ejemplos
#select validar_cedula("1728143247"), validar_cedula("172814324a"), validar_cedula("123455555555555555");
#funcion para validar la fecha de nacimiento
delimiter \\
CREATE FUNCTION validar_fnac(fnac date)
RETURNS bool
DETERMINISTIC
begin
declare valido bool;
#valida respecto a la diferencia con la fecha actual (18 años=6570 días)
if datediff(curdate(),fnac)>6570 then
set valido=true;
else set valido=false;
end if;
return valido;
end\\
#select validar_fnac("2007-04-02");
#drop function validar_fnac;
#Función para validar el correo
delimiter \\
CREATE FUNCTION validar_correo(correo varchar(250))
RETURNS bool
DETERMINISTIC
begin
declare formato bool;
declare valido bool;
#Expresión regular, que busca una arroba y un punto, también valida el texto entre ellos.
select correo regexp "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+[.][a-zA-Z.]{2,}$" into formato;
if (formato=1 and length(correo)<=128) then set valido=true;
else set valido=false;
end if;
return valido;
end;\\
#select validar_correo("mpar@waaaaaa.es");
#Funcion para validar la direccion
delimiter \\
create function validar_dir(direccion varchar (255))
returns bool
deterministic
begin
declare valido bool;
if length(direccion)<=250 then set valido=true;
else set valido=false;
end if;
return valido;
end;\\
#select validar_dir("Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium");
#Funcion para validar la clave
delimiter \\
create function validar_clave(clave varchar(255))
returns bool
deterministic
begin
declare valido bool;
if length(clave)<=250 then set valido=true;
else set valido=false;
end if;
return valido;
end;\\

#Funcion para encriptar la clave

DELIMITER \\
CREATE FUNCTION encripta(clave varchar(250))
returns varbinary(250)
DETERMINISTIC 
BEGIN
	DECLARE miclave varbinary(250);
    set miclave=compress(clave);
    return miclave;
END\\
DELIMITER \\
CREATE FUNCTION desencripta(clave varbinary(250))
returns varchar(250)
DETERMINISTIC 
BEGIN
	DECLARE miclave varchar(250);
    set miclave=uncompress(clave);
    return miclave;
END\\
#select encripta("abc123");
select desencripta(encripta("abc1234"));
#drop function encripta;
#drop function desencripta;

#Trigger para validar el ingreso de un vendedor
delimiter ++
create trigger validar_ingreso_vendedor before insert on vendedor 
For each row
begin
declare telf_valido bool;
set telf_valido=(validar_telefono(new.usuario_telefono) or isNULL(new.usuario_telefono));
if  (
telf_valido=true and
validar_nombre(new.usuario_nombre)=true and
validar_nombre(new.usuario_apellido)=true and
validar_cedula(new.usuario_cedula)=true and
validar_dir(new.usuario_dirreccion)=true and
validar_correo(new.usuario_correo)=true and
validar_fnac(new.usuario_fnacimiento)=true and
validar_clave(new.usuario_clave)=true and
isNull(new.usuario_estado)) then
set new.usuario_estado='Activo';
set new.usuario_clave=encripta(new.usuario_clave);
else SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Error al ingresar los datos";
end if;
end;++
#drop trigger validar_ingreso_vendedor;

#trigger para validar el ingreso de un comprador
delimiter ++
create trigger validar_ingreso_comprador before insert on comprador
For each row
begin
declare telf_valido bool;
set telf_valido=(validar_telefono(new.usuario_telefono) or isNULL(new.usuario_telefono));
if  (
telf_valido=true and
validar_nombre(new.usuario_nombre)=true and
validar_nombre(new.usuario_apellido)=true and
validar_cedula(new.usuario_cedula)=true and
validar_dir(new.usuario_dirreccion)=true and
validar_correo(new.usuario_correo)=true and
validar_fnac(new.usuario_fnacimiento)=true and
validar_clave(new.usuario_clave)=true and
isNull(new.usuario_estado)) then
set new.usuario_estado='Activo';
set new.usuario_clave=encripta(new.usuario_clave);
else SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Error al ingresar los datos";
end if;
end;++


#triggers para registro en auditoria
delimiter ++
create trigger registrar_ingreso_comprador after insert on comprador
For each row
begin
declare nombre varchar(64);
declare apellido varchar(64);
declare descripcion text;
declare id int;
select new.usuario_id into id;
select new.usuario_nombre into nombre;
select new.usuario_apellido into apellido;
set descripcion=concat("Creacion de usuario N°",nombre," ",apellido," como comprador");
insert into auditoria(auditoria.USUARIO_ID,auditoria.AUDITORIA_FECHA,auditoria.AUDITORIA_DETALLE) values
(id,curdate(),descripcion);
end;++
#drop trigger registrar_ingreso_comprador;
delimiter ++
create trigger registrar_ingreso_vendedor after insert on vendedor
For each row
begin
declare nombre varchar(64);
declare apellido varchar(64);
declare descripcion text;
declare id int;
select new.usuario_id into id;
select new.usuario_nombre into nombre;
select new.usuario_apellido into apellido;
set descripcion=concat("Creacion de usuario N°",nombre," ",apellido," como vendedor");
insert into auditoria(auditoria.USUARIO_ID,auditoria.AUDITORIA_FECHA,auditoria.AUDITORIA_DETALLE) values
(id,now(),descripcion);
end;++
#drop trigger registrar_ingreso_vendedor;


######TRIGGERS AL ACTUALIZAR#######################
delimiter ++
create trigger validar_cambio_vendedor before update on vendedor
For each row
begin
declare telf_valido bool;
declare estado_valido bool;
set telf_valido=(validar_telefono(new.usuario_telefono) or isNULL(new.usuario_telefono));
set estado_valido=(new.usuario_estado='Activo' or new.usuario_estado='Inactivo');
if  (
telf_valido=true and
validar_nombre(new.usuario_nombre)=true and
validar_nombre(new.usuario_apellido)=true and
validar_cedula(new.usuario_cedula)=true and
validar_dir(new.usuario_dirreccion)=true and
validar_correo(new.usuario_correo)=true and
new.usuario_fnacimiento=old.usuario_fnacimiento and
validar_clave(new.usuario_clave)=true and
old.usuario_estado='Activo' and
estado_valido=true
) then
set new.usuario_clave=encripta(new.usuario_clave);
else SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Error al actualizar los datos";
end if;
end;++


delimiter ++
create trigger validar_cambio_comprador before update on comprador
For each row
begin
declare telf_valido bool;
declare estado_valido bool;
set telf_valido=(validar_telefono(new.usuario_telefono) or isNULL(new.usuario_telefono));
set estado_valido=(new.usuario_estado='Activo' or new.usuario_estado='Inactivo');
if  (
telf_valido=true and
validar_nombre(new.usuario_nombre)=true and
validar_nombre(new.usuario_apellido)=true and
validar_cedula(new.usuario_cedula)=true and
validar_dir(new.usuario_dirreccion)=true and
validar_correo(new.usuario_correo)=true and
new.usuario_fnacimiento=old.usuario_fnacimiento and
validar_clave(new.usuario_clave)=true and
old.usuario_estado='Activo' and
estado_valido=true
) then
set new.usuario_clave=encripta(new.usuario_clave);
else SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Error al actualizar los datos";
end if;
end;++
#drop trigger validar_cambio_vendedor;

delimiter ++
create trigger registrar_cambio_vendedor after update on vendedor
For each row
begin
declare nombre varchar(64);
declare apellido varchar(64);
declare cnombre varchar(64);
declare capellido varchar(64);
declare cdir varchar(64);
declare cclave varchar(64);
declare ctelf varchar(64);
declare cced varchar(64);
declare ccorreo varchar(64);
declare cest bool;
declare descripcion text;
declare id int;
select new.usuario_id into id;
select old.usuario_nombre into nombre;
select old.usuario_apellido into apellido;
if new.usuario_estado='Inactivo' then set descripcion=concat("Eliminacion de cuenta del vendedor N°",id," ",nombre," ",apellido);
call eliminar_vendedor(new.usuario_id);
else
if new.usuario_nombre!=old.usuario_nombre then 
set cnombre=concat("Cambio de nombre de",old.usuario_nombre," a ",new.usuario_nombre,",");
else set cnombre=""; 
end if;
if new.usuario_apellido!=old.usuario_apellido then 
set capellido=concat("Cambio de apellido de",old.usuario_apellido," a ",new.usuario_apellido,",");
else set capellido=""; 
end if;
if new.usuario_telefono!=old.usuario_telefono then 
set ctelf=concat("Cambio de telefono de",old.usuario_telefono," a ",new.usuario_telefono,",");
else set ctelf=""; 
end if;
if new.usuario_cedula!=old.usuario_cedula then 
set cced=concat("Cambio de cedula de",old.usuario_cedula," a ",new.usuario_cedula,",");
else set cced=""; 
end if;
if new.usuario_cedula!=old.usuario_clave then 
set cclave=concat("Cambio de clave,");
else set cclave=""; 
end if;
if new.usuario_dirreccion!=old.usuario_dirreccion then 
set cdir=concat("Cambio de direccion de",old.usuario_dirreccion," a ",new.usuario_dirreccion,",");
else set cdir="."; 
end if;
if new.usuario_correo!=old.usuario_correo then 
set ccorreo=concat("Cambio de correo de",old.usuario_correo," a ",new.usuario_correo,",");
else set ccorreo=""; 
end if;
set descripcion=concat("Actualizacion de datos del vendedor N°",nombre," ",apellido," ",cnombre, capellido,cced,ctelf,cclave, ccorreo,cdir);
end if;
insert into auditoria(auditoria.USUARIO_ID,auditoria.AUDITORIA_FECHA,auditoria.AUDITORIA_DETALLE) values
(id,now(),descripcion);
end;++


delimiter ++
create trigger registrar_cambio_comprador after update on comprador
For each row
begin
declare nombre varchar(64);
declare apellido varchar(64);
declare cnombre varchar(64);
declare capellido varchar(64);
declare cdir varchar(64);
declare cclave varchar(64);
declare ctelf varchar(64);
declare cced varchar(64);
declare ccorreo varchar(64);
declare cest bool;
declare descripcion text;
declare id int;
select new.usuario_id into id;
select old.usuario_nombre into nombre;
select old.usuario_apellido into apellido;
if new.usuario_estado='Inactivo' then set descripcion=concat("Eliminacion de cuenta del comprador N°",id," ",nombre," ",apellido);
call eliminar_comprador(new.usuario_id);
else
if new.usuario_nombre!=old.usuario_nombre then 
set cnombre=concat("Cambio de nombre de",old.usuario_nombre," a ",new.usuario_nombre,",");
else set cnombre=""; 
end if;
if new.usuario_apellido!=old.usuario_apellido then 
set capellido=concat("Cambio de apellido de",old.usuario_apellido," a ",new.usuario_apellido,",");
else set capellido=""; 
end if;
if new.usuario_telefono!=old.usuario_telefono then 
set ctelf=concat("Cambio de telefono de",old.usuario_telefono," a ",new.usuario_telefono,",");
else set ctelf=""; 
end if;
if new.usuario_cedula!=old.usuario_cedula then 
set cced=concat("Cambio de cedula de",old.usuario_cedula," a ",new.usuario_cedula,",");
else set cced=""; 
end if;
if new.usuario_cedula!=old.usuario_clave then 
set cclave=concat("Cambio de clave,");
else set cclave=""; 
end if;
if new.usuario_dirreccion!=old.usuario_dirreccion then 
set cdir=concat("Cambio de direccion de",old.usuario_dirreccion," a ",new.usuario_dirreccion,",");
else set cdir="."; 
end if;
if new.usuario_correo!=old.usuario_correo then 
set ccorreo=concat("Cambio de correo de",old.usuario_correo," a ",new.usuario_correo,",");
else set ccorreo=""; 
end if;
set descripcion=concat("Actualizacion de datos del comprador N°",nombre," ",apellido," ",cnombre, capellido,cced,ctelf,cclave, ccorreo,cdir);
end if;
insert into auditoria(auditoria.USUARIO_ID,auditoria.AUDITORIA_FECHA,auditoria.AUDITORIA_DETALLE) values
(id,now(),descripcion);
end;
++
/*drop trigger registrar_ingreso_comprador;
drop trigger registrar_ingreso_vendedor;*/

#####Trigger para eliminar una cuenta
delimiter ++
create procedure eliminar_vendedor(in id INT)
begin
update vehiculo set vehiculo.VEHICULO_ESTADO='Retirado' where usuario_id=id;
end;++

delimiter ++
create procedure eliminar_comprador(in id INT)
begin
update puja set puja.PUJA_ESTADO='Retirado' where usuario_id=id and puja.PUJA_ESTADO='Pendiente';
end;++

#drop trigger registrar_cambio_comprador;
#drop trigger registrar_cambio_vendedor;
