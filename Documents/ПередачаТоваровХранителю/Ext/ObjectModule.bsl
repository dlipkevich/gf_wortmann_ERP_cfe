﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

&Перед("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Склад, "гф_АгентскийСклад") = Истина Тогда
		ДополнительныеСвойства.Вставить("КонтролироватьНомераГТД", Ложь);
	КонецЕсли;
КонецПроцедуры

#КонецЕсли
