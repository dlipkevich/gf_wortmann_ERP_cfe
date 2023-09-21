﻿
&НаКлиенте
Процедура гф_ПриОткрытииПосле(Отказ)
	// Галфинд СадомцевСА 21.09.2023 Реализовал "подписание" документов Заказ на эмиссию КМ внешней обработкой
	// гф_ПодписатьЗаказНаЭмиссию.epf
	Если ТипЗнч(ОписаниеДанных) = Тип("Структура") Тогда
		ТекДокумент = Неопределено;
		Для Каждого Элемент Из ОписаниеДанных.НаборДанных Цикл
			Если Элемент.Данные.Сообщение.Свойство("Документ", ТекДокумент) Тогда
				Прервать;
			КонецЕсли;
		КонецЦикла;
		Если ПодписатьЗаказ(ТекДокумент) Тогда
			Подписать(Неопределено);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПодписатьЗаказ(ТекДокумент)
	ЗаказНаЭмиссиюКМ = Константы.гф_ЗаказНаЭмиссиюКМПодписать.Получить();
	Если ТекДокумент = ЗаказНаЭмиссиюКМ Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции
