#calcular el incremento promedio entre el precio base y el precio final de los autos vendidos, 
#agrupando los resultados por marca y modelo.
delimiter \\
create function calcular_incremento(p_base decimal(7,2), p_venta decimal(7,2))
returns decimal(7,2)
deterministic
begin
declare inc decimal(7,2);
set inc=p_venta-p_base;
return inc; 
end;
\\
create view incremento_promedio as 
select v.VEHICULO_MARCA as "Marca", v.VEHICULO_MODELO as "Modelo", 
calcular_incremento(avg(v.vehiculo_precio_base), avg(p.puja_monto)) as "Incremento"
from vehiculo v inner join puja p on p.VEHICULO_ID=v.VEHICULO_ID where 
p.PUJA_GANADOR=true and v.VEHICULO_ESTADO='Vendido' group by v.VEHICULO_MARCA,v.VEHICULO_MODELO;

drop view incremento_promedio;

#identificar cuáles son los autos que
#han sido subastados en múltiples ocasiones sin haber sido comprados

create view vehiculos_sin_vender as
select v.vehiculo_id as "Vehiculo", 
v.vehiculo_marca as "Marca", 
v.vehiculo_modelo as "Modelo", s.subasta_id as "Subasta"
from subasta_vehiculo s join vehiculo v on s.vehiculo_id=v.vehiculo_id 
where s.subasta_vehiculo_vendido=false order by v.vehiculo_id;

#función para trabajar solo con la fecha
delimiter\\
create function to_fecha(fecha_h datetime)
returns date
deterministic
begin
declare fecha date;
set fecha=fecha_h;
return fecha;
end;\\


#conocer qué usuario ha realizado la mayor cantidad de pujas en un solo día, ordenando los resultados por fecha y total de pujas realizadas.
create view max_pujas_dia as
select fecha, usuario, max(pujas_dia) from (
select to_fecha(puja_fecha) as "fecha", usuario_id as "usuario", count(*) as "pujas_dia" from puja 
group by usuario_id,to_fecha(puja_fecha) order by to_fecha(puja_fecha),pujas_dia desc
) as sb group by fecha;

#select * from max_pujas_dia;