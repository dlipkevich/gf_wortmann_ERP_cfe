﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	Если ЭтоНовый() Тогда
		Ответственный = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
КонецПроцедуры

&Вместо("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли