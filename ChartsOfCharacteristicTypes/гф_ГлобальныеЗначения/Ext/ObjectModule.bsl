﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

&После("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ПустаяСтрока(Ключ) Тогда
		_омОбщегоНазначенияКлиентСервер.УстановитьЗначение(Ключ, СокрЛП(Ключ));
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Ключ", Ключ);
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	т.Ссылка КАК Ссылка
		|ИЗ
		|	ПланВидовХарактеристик.гф_ГлобальныеЗначения КАК т
		|ГДЕ
		|	т.Ключ = &Ключ
		|	И т.Ссылка <> &Ссылка";
		
		Если Не Запрос.Выполнить().Пустой() Тогда
			пТекст = "Ошибка при записи объекта: " + Строка(ЭтотОбъект) + "
			|Ключ объекта не уникальный!";
			
			_омОбщегоНазначенияКлиентСервер.СообщитьОбОшибке(пТекст, Отказ);
		КонецЕсли;
	КонецЕсли;
	
	Если Предопределенный И ПустаяСтрока(Ключ) Тогда
		Ключ = ИмяПредопределенныхДанных;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли