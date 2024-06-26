﻿
#Область ОбработчикиСобытийФормы
// #wortmann {
// устанавливает параметр в ТЧ Товары
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/02  
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)	
	
	// vvv Галфинд \ Sakovich 23.01.2023
	//СкладУпаковки = Параметры["СкладУпаковки"];
	//ЗаполнитьСписокУЛ(СкладУпаковки);
	Организация = Параметры["Организация"];
	ДатаПодбора = Параметры["ДатаПодбора"];
	СкладУпаковки = Параметры["СкладУпаковки"];
	ЗаполнитьСписокУЛ(СкладУпаковки, Организация, ДатаПодбора);
	// ^^^ Галфинд \ Sakovich 23.01.2023 
	
	Товары.Параметры.УстановитьЗначениеПараметра("УпаковочныйЛист", Истина);
	
КонецПроцедуры// } #wortmann 

#КонецОбласти 
#Область ОбработчикиСобытийЭлементовШапкиФормы

// #wortmann {
// устанавливает параметр в ТЧ Товары при переходе на новую строку
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/02 
&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	
	ТекущиеДанные = Элементы.СписокУЛ.ТекущиеДанные;	
	Если ТекущиеДанные <> Неопределено Тогда
		Товары.Параметры.УстановитьЗначениеПараметра("УпаковочныйЛист", ТекущиеДанные.УпаковочныйЛист);
	Иначе
		Товары.Параметры.УстановитьЗначениеПараметра("УпаковочныйЛист", Истина);
	КонецЕсли;
	
КонецПроцедуры// } #wortmann

#КонецОбласти

#Область ОбработчикиКомандФормы

// #wortmann {
// формирование массива строк для передачи в док ПеремещениеТоваров
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/02 
&НаКлиенте
Процедура ЗавершитьПодбор(Команда)
	
	МассивВыделенных = СписокУЛ.НайтиСтроки(Новый Структура("Пометка",Истина));
		
	МассивВыбранных = Новый Массив; 

	Для каждого ИденСтроки Из МассивВыделенных Цикл
		
		СтруСтроки = Новый Структура("УпаковочныйЛист, Артикул, IDКороба, КоличествоПар");
		
		ЗаполнитьЗначенияСвойств(СтруСтроки, ИденСтроки);
		
		МассивВыбранных.Добавить(СтруСтроки);
		
	КонецЦикла;

	Закрыть(МассивВыбранных);
	
КонецПроцедуры// } #wortmann 

//+++ БФ Бобнев К.С. 29.03.24
&НаКлиенте
Процедура бф_ОтметитьПоСписку(Команда)
	ОписаниеОповещения = Новый ОписаниеОповещения("бф_ПослеЗакрытияТабДока", ЭтотОбъект);
	ОткрытьФорму("Документ.УпаковочныйЛист.Форма.бф_ФормаЗагрузкиИзТабличногоДокумента",, ЭтотОбъект,,,, ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры
//--- БФ Бобнев К.С. 29.03.24

#КонецОбласти

#Область СлужебныеПроцедурыИФункции 

// #wortmann { 
// Заполнение ТЗ СписокУЛ
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/02
&НаСервере
Процедура ЗаполнитьСписокУЛ(СкладУпаковки, Организация, ДатаПодбора)	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	спрШтриходы.Ссылка КАК Ссылка,
	|	спрШтриходы.ЗначениеШтрихкода КАК ЗначениеШтрихкода
	|ПОМЕСТИТЬ втУпаковкиКМ
	|ИЗ
	|	Справочник.ШтрихкодыУпаковокТоваров КАК спрШтриходы
	|ГДЕ
	|	спрШтриходы.ТипУпаковки = ЗНАЧЕНИЕ(Перечисление.ТипыУпаковок.МультитоварнаяУпаковка)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОстаткиКМ.Организация КАК Организация,
	|	ОстаткиКМ.Склад КАК Склад,
	|	ОстаткиКМ.КМ КАК КМ,
	|	ОстаткиКМ.КоличествоОстаток КАК КоличествоОстаток
	|ПОМЕСТИТЬ ОстаткиКМ
	|ИЗ
	|	РегистрНакопления.гф_ДвижениеКодовМаркировкиОрганизации.Остатки(
	|			&ДатаПодбора,
	|			Организация = &Организация
	|				И Склад = &СкладУпаковки
	|				И КМ В
	|					(ВЫБРАТЬ
	|						т.Ссылка
	|					ИЗ
	|						втУпаковкиКМ КАК т)) КАК ОстаткиКМ
	|ГДЕ
	|	ОстаткиКМ.КоличествоОстаток > 0
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	УпаковочныйЛист.Ссылка КАК УпаковочныйЛист,
	|	УпаковочныйЛист.Код КАК IDКороба,
	|	УпаковочныйЛист.ВсегоМест КАК КоличествоПар,
	|	ЛОЖЬ КАК Пометка,
	|	Номенклатура.Артикул КАК Артикул
	|ИЗ
	|	ОстаткиКМ КАК ОстаткиКМ
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.УпаковочныйЛист КАК УпаковочныйЛист
	|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВариантыКомплектацииНоменклатуры КАК ВариантыКомплектацииНоменклатуры
	|				ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК Номенклатура
	|				ПО ВариантыКомплектацииНоменклатуры.Владелец = Номенклатура.Ссылка
	|			ПО УпаковочныйЛист.гф_Комплектация = ВариантыКомплектацииНоменклатуры.Ссылка
	|		ПО ОстаткиКМ.КМ = УпаковочныйЛист.гф_Агрегация
	|
	|УПОРЯДОЧИТЬ ПО
	|	IDКороба,
	|	Артикул";
	
	Запрос.УстановитьПараметр("СкладУпаковки", СкладУпаковки);
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("ДатаПодбора", ДатаПодбора);
	
	Результат = Запрос.Выполнить().Выбрать();
	Пока Результат.Следующий() Цикл
		НоваяСтрока = СписокУЛ.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока,Результат);
	КонецЦикла;
	
КонецПроцедуры// } #wortmann

//+++ БФ Бобнев К.С. 29.03.24
&НаКлиенте
Процедура бф_ПослеЗакрытияТабДока(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(Результат) <> Тип("ТабличныйДокумент") Тогда
		Возврат;
	КонецЕсли;
	
	Счетчик = 0;
	
	Для ъ = 2 По Результат.ВысотаТаблицы Цикл
		IDКороба = Результат.Область(ъ, 1, ъ, 1).Текст;
		Если ЗначениеЗаполнено(IDКороба) Тогда
			НайденныеСтроки = СписокУЛ.НайтиСтроки(Новый Структура("IDКороба", IDКороба));
			Если НайденныеСтроки.Количество() = 0 Тогда
				ОбщегоНазначенияКлиент.СообщитьПользователю("Упаковочный лист " + IDКороба + " не найден");
			ИначеЕсли НайденныеСтроки.Количество() > 1 Тогда
				ОбщегоНазначенияКлиент.СообщитьПользователю("Найдено несколько упаковочных листов с ID " + IDКороба);
			Иначе
				НайденныеСтроки[0].Пометка = Истина;
				Счетчик = Счетчик + 1;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;                       

	ОбщегоНазначенияКлиент.СообщитьПользователю("Отмечены упаковочные листы: " + Счетчик + " шт.");
	
КонецПроцедуры

//--- БФ Бобнев К.С. 29.03.24

#КонецОбласти
