﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

&Вместо("ОбработкаПроверкиЗаполнения")
Процедура гф_ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	// #wortmann { 
	// Заполняем Наименование элемента согласно наименованию Организации 
	// Галфинд_Домнышева 2022/12/15
	Наименование = Организация.Наименование;
	ПродолжитьВызов(Отказ, ПроверяемыеРеквизиты); 
	// } #wortmann
КонецПроцедуры

#КонецЕсли