﻿#Если НЕ МобильныйАвтономныйСервер Тогда
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий 

&После("ОбработкаПроверкиЗаполнения")
Процедура гф_ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(B2B_Портал) Тогда
		ПроверяемыеРеквизиты.Добавить("B2B_ГруппаНаСайтеОсновная");
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
#КонецЕсли

