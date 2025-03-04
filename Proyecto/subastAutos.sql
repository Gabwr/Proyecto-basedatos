/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     3/3/2025 21:40:04                            */
/*==============================================================*/

/*==============================================================*/
/* Table: AUDITORIA                                             */
/*==============================================================*/
create table AUDITORIA
(
   AUDITORIA_ID         int not null auto_increment,
   COM_USUARIO_ID       int,
   VEN_USUARIO_ID       int,
   AUDITORIA_FECHA      datetime not null,
   AUDITORIA_DETALLE    text not null,
   primary key (AUDITORIA_ID)
);

/*==============================================================*/
/* Table: COMPRADOR                                             */
/*==============================================================*/
create table COMPRADOR
(
   USUARIO_ID           int not null auto_increment,
   USUARIO_NOMBRE       varchar(64) not null,
   USUARIO_APELLIDO     varchar(64) not null,
   USUARIO_CEDULA       varchar(11) not null,
   USUARIO_FNACIMIENTO  date not null,
   USUARIO_CORREO       varchar(128) not null,
   USUARIO_CLAVE        varchar(250) not null,
   USUARIO_TELEFONO     varchar(11),
   USUARIO_DIRRECCION   varchar(250) not null,
   USUARIO_ESTADO       varchar(32) not null,
   primary key (USUARIO_ID)
);

/*==============================================================*/
/* Table: PAGO                                                  */
/*==============================================================*/
create table PAGO
(
   PAGO_ID              int not null auto_increment,
   PUJA_ID              int not null,
   PAGO_FECHA           date,
   PAGO_FECHA_LIMITE    date,
   PAGO_ESTADO          varchar(16) default 'pendiente',
   /*estado: pendiente, pagado, cancelado*/
   PAGO_METODO          varchar(64) default "por definir",
   /*metodos de pago: por definir (inicial), efectivo, tarjeta de credito, tarjeta de debito,
   transferencia, online*/
   primary key (PAGO_ID)
);

/*==============================================================*/
/* Table: PUJA                                                  */
/*==============================================================*/
create table PUJA
(
   PUJA_ID              int not null auto_increment,
   USUARIO_ID           int not null,
   SUBASTA_ID           int not null,
   VEHICULO_ID          int not null,
   PUJA_MONTO           decimal(7,2) not null,
   PUJA_FECHA           datetime not null,
   PUJA_GANADOR         bool,
   PUJA_ESTADO          varchar(16) default 'activo',
   primary key (PUJA_ID)
);

/*==============================================================*/
/* Table: SUBASTA                                               */
/*==============================================================*/
create table SUBASTA
(
   SUBASTA_ID           int not null auto_increment,
   SUBASTA_FECHA_INICIO datetime not null,
   SUBASTA_FECHA_FIN    datetime not null,
   SUBASTA_VIGENTE      bool,
   primary key (SUBASTA_ID)
);

/*==============================================================*/
/* Table: SUBASTA_VEHICULO                                      */
/*==============================================================*/
create table SUBASTA_VEHICULO
(
   VEHICULO_ID          int not null,
   SUBASTA_ID           int not null,
   SUBASTA_VEHICULO_VENDIDO bool default false,
   primary key (VEHICULO_ID, SUBASTA_ID)
);

/*==============================================================*/
/* Table: VEHICULO                                              */
/*==============================================================*/
create table VEHICULO
(
   VEHICULO_ID          int not null auto_increment,
   USUARIO_ID           int not null,
   VEHICULO_MARCA       varchar(64) not null,
   VEHICULO_MODELO      varchar(64) not null,
   VEHICULO_ANIO        int not null,
   VEHICULO_PRECIO_BASE decimal(5,2) not null,
   VEHICULO_PLACA       varchar(10) not null,
   VEHICULO_COLOR       varchar(32) not null,
   VEHICULO_KILOMETRAJE bigint not null,
   VEHICULO_ESTADO      varchar(32) default 'disponible',
	/*Estado puede ser disponible, vendido o retirado*/
   primary key (VEHICULO_ID)
);

/*==============================================================*/
/* Table: VENDEDOR                                              */
/*==============================================================*/
create table VENDEDOR
(
   USUARIO_ID           int not null auto_increment,
   USUARIO_NOMBRE       varchar(64) not null,
   USUARIO_APELLIDO     varchar(64) not null,
   USUARIO_CEDULA       varchar(11) not null,
   USUARIO_FNACIMIENTO  date not null,
   USUARIO_CORREO       varchar(128) not null,
   USUARIO_CLAVE        varchar(250) not null,
   USUARIO_TELEFONO     varchar(11),
   USUARIO_DIRRECCION   varchar(250) not null,
   USUARIO_ESTADO       varchar(32) not null,
   primary key (USUARIO_ID)
);

alter table AUDITORIA add constraint FK_FK_CONTROLA foreign key (COM_USUARIO_ID)
      references COMPRADOR (USUARIO_ID) on delete restrict on update restrict;

alter table AUDITORIA add constraint FK_FK_CONTROLA2 foreign key (VEN_USUARIO_ID)
      references VENDEDOR (USUARIO_ID) on delete restrict on update restrict;

alter table PAGO add constraint FK_FK_CORRESPONDE2 foreign key (PUJA_ID)
      references PUJA (PUJA_ID) on delete restrict on update restrict;

alter table PUJA add constraint FK_FK_REALIZA foreign key (USUARIO_ID)
      references COMPRADOR (USUARIO_ID) on delete restrict on update restrict;

alter table PUJA add constraint FK_FK_TIENE foreign key (SUBASTA_ID)
      references SUBASTA (SUBASTA_ID) on delete restrict on update restrict;

alter table PUJA add constraint FK_FK_VEHICULO_PUJA foreign key (VEHICULO_ID)
      references VEHICULO (VEHICULO_ID) on delete restrict on update restrict;

alter table SUBASTA_VEHICULO add constraint FK_FK_SUBASTA_VEHICULO foreign key (VEHICULO_ID)
      references VEHICULO (VEHICULO_ID) on delete restrict on update restrict;

alter table SUBASTA_VEHICULO add constraint FK_FK_SUBASTA_VEHICULO2 foreign key (SUBASTA_ID)
      references SUBASTA (SUBASTA_ID) on delete restrict on update restrict;

alter table VEHICULO add constraint FK_FK_REGISTRA foreign key (USUARIO_ID)
      references VENDEDOR (USUARIO_ID) on delete restrict on update restrict;

