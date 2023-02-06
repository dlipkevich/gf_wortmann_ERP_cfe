﻿
&После("ПриЗаполненииОграниченияДоступа")
Процедура гф_ПриЗаполненииОграниченияДоступа(Ограничение)
	// #wortmann { 
	// Внесение изменений для ограничения чтения с производительным RLS
	// Галфинд_Домнышева 2022/11/23 
	Ограничение.Текст =
	"РазрешитьЧтение
	|ГДЕ 
	|	ЗначениеРазрешено(Владелец)
	|;
	|РазрешитьИзменениеЕслиРазрешеноЧтение
	|ГДЕ
	|	ЗначениеРазрешено(Владелец)";
	// } #wortmann
КонецПроцедуры
