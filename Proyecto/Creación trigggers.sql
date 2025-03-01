/* marcelo: usuarios (vendores y compradores)
   gabriel : subasta_vehiculos y procedures beta
   mateo: pujas y subastas
   alejandro vehiculos y pagos
*/
/* script de prueba*/
-- Insertar Vendedores
INSERT INTO VENDEDOR (USUARIO_NOMBRE, USUARIO_APELLIDO, USUARIO_CEDULA, USUARIO_FNACIMIENTO, USUARIO_CORREO, USUARIO_CLAVE, USUARIO_TELEFONO, USUARIO_DIRRECCION, USUARIO_ESTADO)
VALUES 
('Carlos', 'Gomez', '1234567890', '1985-06-15', 'carlos@gmail.com', 'clave123', '0987654321', 'Av. Principal 123', 'Activo'),
('Ana', 'Martinez', '0987654321', '1990-04-20', 'ana@gmail.com', 'clave456', '0976543210', 'Calle Secundaria 456', 'Activo'),
('Luis', 'Fernandez', '1122334455', '1982-11-30', 'luis@gmail.com', 'clave789', '0965432109', 'Av. Central 789', 'Activo');

-- Insertar Compradores
INSERT INTO COMPRADOR (USUARIO_NOMBRE, USUARIO_APELLIDO, USUARIO_CEDULA, USUARIO_FNACIMIENTO, USUARIO_CORREO, USUARIO_CLAVE, USUARIO_TELEFONO, USUARIO_DIRRECCION, USUARIO_ESTADO)
VALUES 
('Maria', 'Lopez', '2233445566', '1995-02-10', 'maria@gmail.com', 'pass123', '0954321098', 'Calle A 100', 'Activo'),
('Pedro', 'Ramirez', '3344556677', '1988-09-25', 'pedro@gmail.com', 'pass456', '0943210987', 'Av. B 200', 'Activo'),
('Sofia', 'Hernandez', '4455667788', '1992-07-14', 'sofia@gmail.com', 'pass789', '0932109876', 'Calle C 300', 'Activo');

-- Insertar Vehículos (asignando a los vendedores creados, IDs del 1 al 3)
INSERT INTO VEHICULO (USUARIO_ID, VEHICULO_MARCA, VEHICULO_MODELO, VEHICULO_ANIO, VEHICULO_PRECIO_BASE, VEHICULO_PLACA, VEHICULO_COLOR, VEHICULO_KILOMETRAJE, VEHICULO_ESTADO)
VALUES 
(1, 'Toyota', 'Corolla', 2018, 12000.00, 'ABC1234', 'Rojo', 50000, 'Disponible'),
(2, 'Honda', 'Civic', 2020, 15000.00, 'DEF5678', 'Azul', 30000, 'Disponible'),
(3, 'Ford', 'Focus', 2017, 10000.00, 'GHI9012', 'Negro', 70000, 'Disponible');

-- Insertar Subasta
INSERT INTO SUBASTA (SUBASTA_FECHA_INICIO, SUBASTA_FECHA_FIN, SUBASTA_VIGENTE)
VALUES ('2025-03-01 10:00:00', '2025-03-10 18:00:00', TRUE);

-- Asociar Vehículos a la Subasta
INSERT INTO SUBASTA_VEHICULO (VEHICULO_ID, SUBASTA_ID, SUBASTA_VEHICULO_VENDIDO)
VALUES 
(1, 1, FALSE),
(2, 1, FALSE),
(3, 1, FALSE);

-- Insertar Pujas (asignando a los compradores creados, IDs del 1 al 3)
INSERT INTO PUJA (VEHICULO_ID, SUBASTA_ID, USUARIO_ID, PUJA_MONTO, PUJA_FECHA, PUJA_GANADOR, PUJA_ESTADO)
VALUES 
(1, 1, 1, 12500.00, '2025-03-02 12:00:00', FALSE, 'Pendiente'),
(2, 1, 2, 15500.00, '2025-03-03 14:00:00', FALSE, 'Pendiente'),
(3, 1, 3, 10500.00, '2025-03-04 16:00:00', FALSE, 'Pendiente');

-- Insertar un pago para una puja específica
INSERT INTO PAGO (PUJA_ID, PAGO_FECHA, PAGO_FECHA_LIMITE, PAGO_ESTADO, PAGO_METODO)
VALUES (1, '2025-03-05', '2025-03-10', 'Pendiente', 'Transferencia bancaria');

/*fin script pruebas*/
/* Definición pujas*/
INSERT INTO PUJA (VEHICULO_ID, SUBASTA_ID, USUARIO_ID, PUJA_MONTO, PUJA_FECHA, PUJA_GANADOR, PUJA_ESTADO)
VALUES (5, 4, 100, 12500.00, '2025-03-02 12:00:00', FALSE, 'Pendiente');
/*antes de insercion:
	si usuario id tiene estado= cuenta desactivada -> no puede ingresar de ese usuario y detiene el ingreso
	fecha de la puja entre la fecha inicial y fecha final de la subasta
    comprobar que en la tabla SUBASTA_VEHICULO este el auto por el que se desea pujar
	monto mayor a la mayor puja actual
    estado que por default sea activo, si no pone nada, que deje, y si pone otra cosa, no deja
    comprobar que el auto no este retirado o ya vendido
despues de la insercion:
	calcular si es ganador a partir de las pujas al mismo auto
	en auditoria cargar el id del usuario, la fecha de realización  y el detalle que sea puja
*/

/*cuando la subasta se termine, se calcula el ganador, se obtiene el resultado del ganador
	con la puja ganadora crear la funcion hacer pago
*/

/* calcular ganador solo tomara en cuentas pujas de estado activo*/

/*antes de update:
	solo se puede editar el estado que son activo o retirado
despues de la update:
	si es activo, no pasa nada y se calcula si es ganador
    si es retirado, no se calcula si es ganador
    En auditoria se registra el id del usuario con la puja retirada, fecha de realización 
    y en detalle puja retirada
*/

/* Definición usuarios*/
INSERT INTO VENDEDOR (USUARIO_NOMBRE, USUARIO_APELLIDO, USUARIO_CEDULA, USUARIO_FNACIMIENTO, USUARIO_CORREO, USUARIO_CLAVE, USUARIO_TELEFONO, USUARIO_DIRRECCION, USUARIO_ESTADO)
VALUES 
('Carlos', 'Gomez', '1234567890', '1985-06-15', 'carlos@gmail.com', 'clave123', '0987654321', 'Av. Principal 123', 'Activo');
INSERT INTO COMPRADOR (USUARIO_NOMBRE, USUARIO_APELLIDO, USUARIO_CEDULA, USUARIO_FNACIMIENTO, USUARIO_CORREO, USUARIO_CLAVE, USUARIO_TELEFONO, USUARIO_DIRRECCION, USUARIO_ESTADO)
VALUES 
('Maria', 'Lopez', '2233445566', '1995-02-10', 'maria@gmail.com', 'pass123', '0954321098', 'Calle A 100', 'Activo');
/*los dos deben tener precargado de ley el usuario 0 como administrador*/

/*antes de insercion:
	nombre y apellido solo letras y que no se pase de los char definidos
	cedula solo numeros e igual a 10 
    fecha nacimiento, se calcula la edad que sea mayor a 18 años *opcional menor de 80 años
    usuario que no se pase de los char definidos
    clave que no se pase de los char definidos
    correo que tenga algo@correo.algo y que no se pase de los char definidos
    telefono que sea numeros igual a 10 pero deje pasar que este nulo
    dirreción que no se pase de los char definidos
    estado default activo, si no pone nada, que deje pasar, y si pone algo, no deje
    
    encriptar la clave justo despues de toda la comprobación
despues de la insercion:
    en auditoria agregar id del usuario agregado, fecha de realización y detalle que sea creacion de cuenta
*/

/*antes de update:
	si usuario id tiene estado= cuenta desactivada -> no puede actualizar de ese usuario y detiene la actualización
	nombre y apellido solo letras y que no se pase de los char definidos
	cedula solo numeros e igual a 10 
    fecha nacimiento, no se debe cambiar
    usuario que no se pase de los char definidos
    clave que no se pase de los char definidos
    correo que tenga algo@correo.algo y que no se pase de los char definidos
    telefono que sea numeros igual a 10 pero deje pasar que este nulo
    dirreción que no se pase de los char definidos
    estado que cumpla con los casos: activo o cuenta desactivada
    si cuenta esta en estado desactivada, no se puede volver a activar
    
    encriptar la clave justo despues de toda la comprobación
despues de la update:
    Si estado es cuenta desactivada, auditoria que guarde el usuario que desactivo su cuenta, 
    fecha de realización y que detalle sea desactivacion cuenta
	si la cuenta se desactiva y es vendedor entonces, 
    todos los autos con el id del vendedor tienen el estado retirado
    si la cuenta se desactiva y es comprador,
    todas las pujas activas en subastas activas son retiradas
*/
	
/*Definición pago*/
INSERT INTO PAGO (PUJA_ID, PAGO_FECHA, PAGO_FECHA_LIMITE, PAGO_ESTADO, PAGO_METODO)
VALUES (1, '2025-03-05', '2025-03-10', 'pendiente', 'transferencia_bancaria');
/*antes de insercion
	fecha limite 1 mes desde la creación del pago
    metodo de pago que solo sea tarjeta de credito, tarjeta de debito, transferencia, efectivo y pago por terceros
    estado que si esta vacio le deje pasar por que hay default pendiente,
    pero si pone algo no deje la inserción
despues de la insercion:
	en auditoria cargar el id del usuario, la fecha de realización  y el detalle que sea pago pendiente creado
*/

/* la funcion hacer pago hace el insertar llamada desde subasta*/

/* cuando el pago fecha fin se queda por debajo de la fecha actual
pago estado=retirado, es una función que realiza este cambio y se llama a la función calcular ganador*/

/*antes de update:
	fecha limite no se puede cambiar 
    estado solo sea o completado, pendiente o retirado, sino no deja actualizar
despues de la update:
	si estado es completado, la fecha de pago se pone la de ese dia
    y tambien en SUBASTA_VEHICULO_VENDIDO se coloca true
    en VEHICULO se pone en estado que sea vendido
    
    si estado es retirado, se llama otra vez a la función 
    calcular ganador para la creación de un nuevo pago
    
    en auditoria cargar el id del usuario, la fecha de realización 
    y el detalle que sea pago pendiente si el estado es pendiente, 
    y si completado, detalle que sea pago completado
    y si es retirado el pago, el detalle es pago retirado
*/



/*Definición vehiculo*/
INSERT INTO VEHICULO (USUARIO_ID, VEHICULO_MARCA, VEHICULO_MODELO, VEHICULO_ANIO, VEHICULO_PRECIO_BASE, VEHICULO_PLACA, VEHICULO_COLOR, VEHICULO_KILOMETRAJE, VEHICULO_ESTADO)
VALUES 
(1, 'Toyota', 'Corolla', 2018, 12000.00, 'ABC1234', 'Rojo', 50000, 'disponible');
/*antes de insercion
	marca solo letras y que no se pase de los varchar establecidos
    placa no se pase de 10 caracteres y que solo admita letras, numeros
    modelo que no se pase de los varchar establecidos
    anio no sobrepase el anio actual
    precio base mayor que $2000.99
    color solo letras  y que no se pase de los varchar establecidos
    que estado por default sea disponible, y si deja nulo, que de paso 
    otra cosa no deja
    kilometraje mayor que 0
despues de la insercion:
	 en auditoria cargar el id del usuario que realizo la inserción, la fecha de realización 
    y el detalle que sea insercion vehiculo
*/

/*antes de update:
	solo se puede cambiar el estado a vendido, disponible y retirado
despues de la update:
    si el auto tiene el estado  retirado, 
    entonces las pujas de ese auto se desactivan si este no ha sido vendido comprobado en la tabla SUBASTA_VEHICULO
    osea no esta en ninguna subasta
    y se agrega en auditoria con la fecha de realización el id del usuario y en detalle que sea retiro auto
*/

/*Definición subasta*/
INSERT INTO SUBASTA (SUBASTA_FECHA_INICIO, SUBASTA_FECHA_FIN, SUBASTA_VIGENTE)
VALUES ('2025-03-01 10:00:00', '2025-03-10 18:00:00', TRUE);
/*antes de insercion
	fecha inicio, solo sea la fecha de hoy
despues de la insercion:
	fecha fin se pone 30 dias despues de fecha inicio
    en auditoria cargar el id del usuario que realizo la inserción, la fecha de realización 
    y el detalle que sea apertura subasta
*/

/* procedimiento que calcule subasta vigente a partir de fecha fin y el dia actual*/

/*antes de update:
	se puede extender la fecha fin pero solo mas que el valor anterior
    cambiar la vigencia solo si es true, si es false no se puede hacer nada (se muere)
despues de la update:
	si se extiende la fecha del fin de la subasta
	auditoria cargar el que realizo la inserción, la fecha de realización 
    y el detalle que sea subasta extension el usuario sera el admin por default
    
    si la vigencia es false
    se llama a la función calcular ganador para enviar el pago
    auditoria cargar el que realizo la inserción, la fecha de realización 
    y el detalle que sea subasta vigencia acabada el usuario sera el admin por default
*/

/*Definición subasta_vehiculo*/
INSERT INTO SUBASTA_VEHICULO (VEHICULO_ID, SUBASTA_ID, SUBASTA_VEHICULO_VENDIDO)
VALUES 
(1, 1, FALSE);
/*antes de insercion
	subasta tiene que estar vigente
    si vehiculo tiene estado retirado o vendido no dejar
    default de SUBASTA_VEHICULO_VENDIDO es false, si no pone nada, deja pasar, otra cosa no deja
despues de la insercion:
    en auditoria cargar el id del usuario que realizo la inserción, la fecha de realización 
    y el detalle que sea inscripcion subasta 
*/

/* procedimiento que calcule subasta vigente a partir de fecha fin y el dia actual*/

/*antes de update:
	solo se puede cambiar SUBASTA_VEHICULO_VENDIDO a traves de puja y si se realizo el pago,
    continua, caso contrario, nel pastel
despues de la update:
	auditoria cargar el id del usuario que realizo la inserción, la fecha de realización 
    y el detalle que sea vehiculo vendido
*/