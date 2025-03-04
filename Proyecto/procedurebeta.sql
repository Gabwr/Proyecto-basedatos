DELIMITER //
CREATE PROCEDURE subasta_en_vigencia (IN subastaid int)
BEGIN
	DECLARE fecha_init_subasta DATETIME;
    DECLARE fecha_end_subasta DATETIME;
    DECLARE fecha_hoy DATETIME;
    DECLARE ID_subasta INT; 
    DECLARE mensaje VARCHAR(255);
    
	/*Revisa que la subasta exista*/
    SELECT SUBASTA_ID  INTO ID_subasta FROM SUBASTA sb WHERE sb.SUBASTA_ID= subastaid;
    IF ID_subasta = null THEN
        SELECT 'No se puede consultar el tiempo de una subasta no existente' AS Mensaje;
        RETURN NULL;
    END IF;
    
    /*Comprueba que este detro de una subasta aun activa*/
    SET fecha_hoy = CURRENT_TIMESTAMP;
	SELECT sb.SUBASTA_FECHA_INICIO INTO fecha_init_subasta 
    FROM SUBASTA sb WHERE sb.SUBASTA_ID= subastaid ;
	
    SELECT sb.SUBASTA_FECHA_FIN INTO fecha_end_subasta 
    FROM SUBASTA sb WHERE sb.SUBASTA_ID= subastaid ;
    
    IF fecha_hoy NOT BETWEEN fecha_init_subasta AND fecha_end_subasta THEN
		IF SUBASTA_VIGENTE IS TRUE THEN 
			UPDATE SUBASTA SET SUBASTA_VIGENTE = FALSE WHERE SUBASTA_ID = NEW.SUBASTA_ID;
		END IF;
        SET mensaje = CONCAT('Subasta ', subastaid, ' ha finalizado');
    ELSE
		IF SUBASTA_VIGENTE IS FALSE THEN 
			UPDATE SUBASTA SET SUBASTA_VIGENTE = TRUE WHERE SUBASTA_ID = NEW.SUBASTA_ID;
		END IF;
        SET mensaje = CONCAT('Subasta ', subastaid, ' sigue abierta');
    END IF;
    
    SELECT mensaje AS Mensaje;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE subasta_envio_pago (IN subastaid int)
BEGIN
    DECLARE ID_subasta INT; 
    DECLARE vigencia bool;
    DECLARE mensaje VARCHAR(255);
    DECLARE ID_usuario int;
    DECLARE usuarionombre VARCHAR(64);
    DECLARE ID_puja int;
    DECLARE ganador bool;
    DECLARE total_pujas INT DEFAULT 0;
    DECLARE contador INT DEFAULT 0;
	/*Revisa que la subasta exista*/
    SELECT SUBASTA_ID INTO ID_subasta FROM SUBASTA sb WHERE sb.SUBASTA_ID= subastaid;
    
    IF ID_subasta = null THEN
        SELECT 'No se puede consultar el tiempo de una subasta no existente' AS Mensaje;
        RETURN NULL;
    END IF;

    SELECT sb.SUBASTA_VIGENTE INTO vigencia FROM SUBASTA sb WHERE sb.SUBASTA_ID= subastaid;
    
       IF (SELECT SUBASTA_VIGENTE FROM SUBASTA WHERE SUBASTA_ID = subastaid) = TRUE THEN
        SELECT CONCAT('La subasta ', subastaid, ' aún sigue en curso, no es posible procesar los datos') AS Mensaje;
        RETURN NULL;
    END IF;
    
   /*Contar cuántas pujas ganadoras hay en la subasta*/
    SELECT COUNT(*) INTO total_pujas FROM PUJA WHERE SUBASTA_ID = subastaid AND PUJA_GANADOR = TRUE;

    /*Si no hay pujas ganadoras, mostrar mensaje y salir*/
    IF total_pujas = 0 THEN
        SELECT CONCAT('Subasta ', subastaid, ' ha finalizado, pero no hubo pujas ganadoras.') AS Mensaje;
        RETURN NULL;
    END IF;
    
    /*Recorrer todas las pujas ganadoras usando un WHILE*/
    WHILE contador < total_pujas DO
        /* Obtener la puja ganadora en la posición actual*/
        SELECT PUJA_ID, USUARIO_ID INTO ID_puja, ID_usuario  FROM PUJA WHERE SUBASTA_ID = subastaid 
        AND PUJA_GANADOR = TRUE LIMIT 1 OFFSET contador;

        /* Obtener el nombre del usuario ganador*/
        SELECT USUARIO_NOMBRE INTO usuarionombre FROM COMPRADOR WHERE USUARIO_ID = ID_usuario;

        /*Insertar el pago asociado a la puja ganadora*/
        INSERT INTO PAGO (PUJA_ID, PAGO_FECHA, PAGO_FECHA_LIMITE, PAGO_ESTADO) 
        VALUES (ID_puja, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'pendiente');

       /*Agregar información al mensaje final*/
        SET mensaje = CONCAT(mensaje, 'Pago registrado para ', usuarionombre, ' por la puja #', ID_puja, '.  en la subasta',subastaid);

        /* Incrementar el contador*/
        SET contador = contador + 1;
    END WHILE;

    SELECT mensaje AS Mensaje;
END//
DELIMITER ;