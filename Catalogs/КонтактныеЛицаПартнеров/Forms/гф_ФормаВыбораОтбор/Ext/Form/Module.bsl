﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("ГруппаДоступа") Тогда
		ОбщегоНазначенияКлиентСервер.УстановитьПараметрДинамическогоСписка(Список, "ГруппаДоступа", Параметры.ГруппаДоступа, Истина);
	КонецЕсли;
	
КонецПроцедуры
