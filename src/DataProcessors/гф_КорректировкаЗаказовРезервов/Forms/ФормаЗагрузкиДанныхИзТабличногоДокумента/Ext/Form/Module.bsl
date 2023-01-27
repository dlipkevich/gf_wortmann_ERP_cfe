﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Заголовок = Параметры.Заголовок;
	ИмяТЧ = Параметры.ИмяТЧ;
	РежимРаботы = Параметры.РежимРаботы;
	Элементы.ЗаказыНаСогласовании.Видимость = ?(РежимРаботы = 0, Истина, Ложь);
	Элементы.РезервыПоЗаказам.Видимость = ?(РежимРаботы = 1, Истина, Ложь);
	
	ИмяМакета = ОпределитьИмяМакета(РежимРаботы, ЗаказыНаСогласовании, РезервыПоЗаказам, ИмяТЧ);
	ШапкаМакета = ПолучитьШапкуМакета(ИмяМакета);
	ТабличныйДокумент.Вывести(ШапкаМакета);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Готово(Команда)
	
	Результат = ПодготовитьРезультат();
	ОповеститьОВыборе(Результат);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытьФорму(Команда)
	
	Закрыть(Неопределено);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Функция ЗаголовокКодУпаковки()
	
	Возврат НСтр("ru = 'Код упаковки';
				|en = 'Код упаковки'");
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ЗаголовокКодМаркировки()
	
	Возврат НСтр("ru = 'ID короба';
				|en = 'ID короба'");
	
КонецФункции

// Резервы по заказам (0/1/2/3)
// ИмяТЧ: "Резервы"/"РезервыВКоробах"
&НаКлиенте
Процедура ЗаполнитьСтруктуруКолонкиПоРезервам(СтруктураКолонки)
	СтруктураКолонки.КолонкаАртикул = ?(ИмяТЧ = "Резервы", 1, 0);
	СтруктураКолонки.КолонкаХарактеристика = ?(ИмяТЧ = "Резервы", 2, 0);
	СтруктураКолонки.КолонкаВариантКомплектации = ?(ИмяТЧ = "Резервы", 0, 1);
	Если РезервыПоЗаказам = 0 Тогда
		СтруктураКолонки.КолонкаЗарезервировать = ?(ИмяТЧ = "Резервы", 3, 2);
	ИначеЕсли РезервыПоЗаказам = 1 Тогда
		СтруктураКолонки.КолонкаСнятьРезерв = ?(ИмяТЧ = "Резервы", 3, 2);
	ИначеЕсли РезервыПоЗаказам = 2 Тогда
		СтруктураКолонки.КолонкаПеренестиРезерв = ?(ИмяТЧ = "Резервы", 3, 2);
		СтруктураКолонки.КолонкаПеренестиРезервНазначение = ?(ИмяТЧ = "Резервы", 4, 3);
	Иначе
		СтруктураКолонки.КолонкаПеренестиДругойЗаказ = ?(ИмяТЧ = "Резервы", 3, 2);
		СтруктураКолонки.КолонкаПеренестиДругойЗаказНазначение = ?(ИмяТЧ = "Резервы", 4, 3);
	КонецЕсли;
КонецПроцедуры

// Заказы на согласовании (0/1)
// ИмяТЧ: "Товары"/"ТоварыВКоробах"
&НаКлиенте
Процедура ЗаполнитьСтруктуруКолонкиПоТоварам(СтруктураКолонки);
	СтруктураКолонки.КолонкаАртикул = ?(ИмяТЧ = "Товары", 1, 0);
	СтруктураКолонки.КолонкаХарактеристика = ?(ИмяТЧ = "Товары", 2, 0);
	СтруктураКолонки.КолонкаВариантКомплектации = ?(ИмяТЧ = "Товары", 0, 1);
	Если ЗаказыНаСогласовании = 0 Тогда
		СтруктураКолонки.КолонкаДобавить = ?(ИмяТЧ = "Товары", 3, 2);
	Иначе
		СтруктураКолонки.КолонкаУдалить = ?(ИмяТЧ = "Товары", 3, 2);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДанныеСтроки(нс, СтруктураКолонки, ТабличныйДокумент, Индекс)
	КолонкаАртикул							= СтруктураКолонки.КолонкаАртикул;
	КолонкаХарактеристика					= СтруктураКолонки.КолонкаХарактеристика;
	КолонкаВариантКомплектации				= СтруктураКолонки.КолонкаВариантКомплектации;
	КолонкаДобавить							= СтруктураКолонки.КолонкаДобавить;
	КолонкаУдалить							= СтруктураКолонки.КолонкаУдалить;
	КолонкаЗарезервировать					= СтруктураКолонки.КолонкаЗарезервировать;
	КолонкаСнятьРезерв						= СтруктураКолонки.КолонкаСнятьРезерв;
	КолонкаПеренестиРезерв					= СтруктураКолонки.КолонкаПеренестиРезерв;
	КолонкаПеренестиРезервНазначение		= СтруктураКолонки.КолонкаПеренестиРезервНазначение;
	КолонкаПеренестиДругойЗаказ				= СтруктураКолонки.КолонкаПеренестиДругойЗаказ;
	КолонкаПеренестиДругойЗаказНазначение	= СтруктураКолонки.КолонкаПеренестиДругойЗаказНазначение;
	
	нс.Артикул							= СокрЛП(?(КолонкаАртикул = 0, "", ТабличныйДокумент.Область(Индекс, КолонкаАртикул).Текст));
	нс.Характеристика					= СокрЛП(?(КолонкаХарактеристика = 0, "", ТабличныйДокумент.Область(Индекс, КолонкаХарактеристика).Текст));
	нс.ВариантКомплектации				= СокрЛП(?(КолонкаВариантКомплектации = 0, "", ТабличныйДокумент.Область(Индекс, КолонкаВариантКомплектации).Текст));
	нс.Добавить							= СокрЛП(?(КолонкаДобавить = 0, "", ТабличныйДокумент.Область(Индекс, КолонкаДобавить).Текст));
	нс.Удалить							= СокрЛП(?(КолонкаУдалить = 0, "", ТабличныйДокумент.Область(Индекс, КолонкаУдалить).Текст));
	нс.Зарезервировать					= СокрЛП(?(КолонкаЗарезервировать = 0, "", ТабличныйДокумент.Область(Индекс, КолонкаЗарезервировать).Текст));
	нс.СнятьРезерв						= СокрЛП(?(КолонкаСнятьРезерв = 0, "", ТабличныйДокумент.Область(Индекс, КолонкаСнятьРезерв).Текст));
	нс.ПеренестиРезерв					= СокрЛП(?(КолонкаПеренестиРезерв = 0, "", ТабличныйДокумент.Область(Индекс, КолонкаПеренестиРезерв).Текст));
	нс.ПеренестиРезервНазначение		= СокрЛП(?(КолонкаПеренестиРезервНазначение = 0, "", ТабличныйДокумент.Область(Индекс, КолонкаПеренестиРезервНазначение).Текст));
	нс.ПеренестиВДругойЗаказ			= СокрЛП(?(КолонкаПеренестиДругойЗаказ = 0, "", ТабличныйДокумент.Область(Индекс, КолонкаПеренестиДругойЗаказ).Текст));
	нс.ПеренестиВДругойЗаказНазначение	= СокрЛП(?(КолонкаПеренестиДругойЗаказНазначение = 0, "", ТабличныйДокумент.Область(Индекс, КолонкаПеренестиДругойЗаказНазначение).Текст));
КонецПроцедуры

// Заполняет Результат из табличного документа в массив структур для возврата вызвавшей форме
//
// Возвращаемое значение:
//   Массив Структур:
//    * Артикул							- Строка
//    * Характеристика					- Строка
//    * ВариантКомплектации				- Строка
//    * Добавить						- Строка
//    * Удалить							- Строка
//    * Зарезервировать					- Строка
//    * СнятьРезерв						- Строка
//    * ПеренестиРезерв					- Строка
//    * ПеренестиРезервНазначение		- Строка
//    * ПеренестиДругойЗаказ			- Строка
//    * ПеренестиДругойЗаказНазначение	- Строка
//
&НаКлиенте
Функция ПодготовитьРезультат()
	
	//РежимРаботы: 0 - На согласовании, 1 - Резервы по заказам
	//ЗаказыНаСогласовании: 0 - Добавить, 1 - Удалить
	//РезервыПоЗаказам: 0 - Зарезервировать, 1 - СнятьРезерв, 2 - Перенести резерв, 3 - Перенести в другой заказ
	//ИмяТЧ: "Товары", "ТоварыВКоробах", "Резервы", "РезервыВКоробах"
	СтруктураКолонки = Новый Структура();
    СтруктураКолонки.Вставить("КолонкаАртикул", 0);
    СтруктураКолонки.Вставить("КолонкаХарактеристика", 0);
    СтруктураКолонки.Вставить("КолонкаВариантКомплектации", 0);
    СтруктураКолонки.Вставить("КолонкаДобавить", 0);
    СтруктураКолонки.Вставить("КолонкаУдалить", 0);
    СтруктураКолонки.Вставить("КолонкаЗарезервировать", 0);
    СтруктураКолонки.Вставить("КолонкаСнятьРезерв", 0);
    СтруктураКолонки.Вставить("КолонкаПеренестиРезерв", 0);
    СтруктураКолонки.Вставить("КолонкаПеренестиРезервНазначение", 0);
    СтруктураКолонки.Вставить("КолонкаПеренестиДругойЗаказ", 0);
    СтруктураКолонки.Вставить("КолонкаПеренестиДругойЗаказНазначение", 0);
	
	Если РежимРаботы = 1 Тогда
		// Резервы по заказам (0/1/2/3)
		// ИмяТЧ: "Резервы"/"РезервыВКоробах"
		ЗаполнитьСтруктуруКолонкиПоРезервам(СтруктураКолонки);
	Иначе
		// Заказы на согласовании (0/1)
		// ИмяТЧ: "Товары"/"ТоварыВКоробах"
		ЗаполнитьСтруктуруКолонкиПоТоварам(СтруктураКолонки);
	КонецЕсли;
	
	Таблица = Новый Массив;
	
	Для Индекс = 2 По ТабличныйДокумент.ВысотаТаблицы Цикл
		
        нс = НоваяСтруктураСтроки();
		ЗаполнитьДанныеСтроки(нс, СтруктураКолонки, ТабличныйДокумент, Индекс);
		Таблица.Добавить(нс);
		
	КонецЦикла;
	
	Результат = Новый Структура("Таблица", Таблица);
	
	Результат.Вставить("РежимРаботы", РежимРаботы);
	Результат.Вставить("ЗаказыНаСогласовании", ЗаказыНаСогласовании);
	Результат.Вставить("РезервыПоЗаказам", РезервыПоЗаказам);
	
	Возврат Результат;
	
КонецФункции

// Проверяет наличие колонки "ID короба" и хотя бы 1 заполненного значения в ней
// 
// Возвращаемое значение:
//   Булево - коды маркировки в таблице есть
//
&НаКлиенте
Функция ЕстьКодыМаркировки()
	
	НомерКолонкиКодМаркировки = Неопределено;
	Для Индекс = 1 По ТабличныйДокумент.ШиринаТаблицы Цикл
		Если ТабличныйДокумент.Область(1,Индекс).Текст = ЗаголовокКодМаркировки() Тогда
			НомерКолонкиКодМаркировки = Индекс;
		КонецЕсли;
	КонецЦикла;
	
	Если НомерКолонкиКодМаркировки = Неопределено Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			СтрШаблон(НСтр("ru = 'Не найдена колонка с заголовком: %1';
							|en = 'Не найдена колонка с заголовком: %1'"), ЗаголовокКодМаркировки()), , "ТабличныйДокумент");
		Возврат Ложь;
	КонецЕсли;
	
	Для Индекс = 2 По ТабличныйДокумент.ВысотаТаблицы Цикл
		Штрихкод = ТабличныйДокумент.Область(Индекс, НомерКолонкиКодМаркировки).Текст;
		Если ЗначениеЗаполнено(Штрихкод) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	ОбщегоНазначенияКлиент.СообщитьПользователю(
		СтрШаблон(НСтр("ru = 'Не заполнена колонка с заголовком: %1';
						|en = 'Не заполнена колонка с заголовком: %1'"), ЗаголовокКодМаркировки()), , "ТабличныйДокумент");
	Возврат Ложь;
	
КонецФункции

&НаСервере
Функция ПолучитьШапкуМакета(ИмяМакета)
	ТабДок = Новый ТабличныйДокумент;
	//ТабДок.АвтоМасштаб = Истина;
	//ТабДок.ОтображатьЗаголовки = Ложь;
	//ТабДок.ОтображатьСетку = Ложь;
	//ТабДок.ТолькоПросмотр = Истина;
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	Макет = ОбработкаОбъект.ПолучитьМакет(ИмяМакета);
	ТабДок.Вывести(Макет);
	Возврат ТабДок;
КонецФункции

&НаСервереБезКонтекста
Функция ОпределитьИмяМакетаПоРезервам(РезервыПоЗаказам, ИмяТЧ)
	// Резервы по заказам (0/1/2/3)
	// ИмяТЧ: "Резервы"/"РезервыВКоробах"
	Если РезервыПоЗаказам = 0 Тогда
		ИмяМакета = ?(ИмяТЧ = "Резервы", "ШаблонРезервыЗарезервировать", "ШаблонРезервыВКоробахЗарезервировать");
	ИначеЕсли РезервыПоЗаказам = 1 Тогда
		ИмяМакета = ?(ИмяТЧ = "Резервы", "ШаблонРезервыСнять", "ШаблонРезервыВКоробахСнять");
	ИначеЕсли РезервыПоЗаказам = 2 Тогда
		ИмяМакета = ?(ИмяТЧ = "Резервы", "ШаблонРезервыПеренести", "ШаблонРезервыВКоробахПеренести");
	Иначе
		ИмяМакета = ?(ИмяТЧ = "Резервы", "ШаблонРезервыДругойЗаказ", "ШаблонРезервыВКоробахДругойЗаказ");
	КонецЕсли;
	Возврат ИмяМакета;
КонецФункции

&НаСервереБезКонтекста
Функция ОпределитьИмяМакетаПоТоварам(ЗаказыНаСогласовании, ИмяТЧ)
	// Заказы на согласовании (0/1)
	// ИмяТЧ: "Товары"/"ТоварыВКоробах"
	Если ЗаказыНаСогласовании = 0 Тогда
		ИмяМакета = ?(ИмяТЧ = "Товары", "ШаблонТоварыДобавить", "ШаблонТоварыВКоробахДобавить");
	Иначе
		ИмяМакета = ?(ИмяТЧ = "Товары", "ШаблонТоварыУдалить", "ШаблонТоварыВКоробахУдалить");
	КонецЕсли;
	Возврат ИмяМакета;
КонецФункции

&НаСервереБезКонтекста
Функция ОпределитьИмяМакета(РежимРаботы, ЗаказыНаСогласовании, РезервыПоЗаказам, ИмяТЧ)
	ИмяМакета = "";
	Если РежимРаботы = 1 Тогда
		// Резервы по заказам (0/1/2/3)
		// ИмяТЧ: "Резервы"/"РезервыВКоробах"
		ИмяМакета = ОпределитьИмяМакетаПоРезервам(РезервыПоЗаказам, ИмяТЧ);
	Иначе
		// Заказы на согласовании (0/1)
		// ИмяТЧ: "Товары"/"ТоварыВКоробах"
		ИмяМакета = ОпределитьИмяМакетаПоТоварам(ЗаказыНаСогласовании, ИмяТЧ);
	КонецЕсли;
	Возврат ИмяМакета;
КонецФункции

&НаКлиенте
Процедура ЗаказыНаСогласованииПриИзменении(Элемент)
	ЗаказыНаСогласованииПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаказыНаСогласованииПриИзмененииНаСервере()
	ТабличныйДокумент.Очистить();
	ИмяМакета = ОпределитьИмяМакета(РежимРаботы, ЗаказыНаСогласовании, РезервыПоЗаказам, ИмяТЧ);
	ШапкаМакета = ПолучитьШапкуМакета(ИмяМакета);
	ТабличныйДокумент.Вывести(ШапкаМакета);
	ТабличныйДокумент.ФиксацияСверху = 1;
КонецПроцедуры

&НаКлиенте
Процедура РезервыПоЗаказамПриИзменении(Элемент)
	РезервыПоЗаказамПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура РезервыПоЗаказамПриИзмененииНаСервере()
	ТабличныйДокумент.Очистить();
	ИмяМакета = ОпределитьИмяМакета(РежимРаботы, ЗаказыНаСогласовании, РезервыПоЗаказам, ИмяТЧ);
	ШапкаМакета = ПолучитьШапкуМакета(ИмяМакета);
	ТабличныйДокумент.Вывести(ШапкаМакета);
	ТабличныйДокумент.ФиксацияСверху = 1;
КонецПроцедуры

&НаСервереБезКонтекста
Функция НоваяСтруктураСтроки()
	СтруктураСтроки = Новый Структура();
	СтруктураСтроки.Вставить("Артикул", "");
	СтруктураСтроки.Вставить("Характеристика", "");
	СтруктураСтроки.Вставить("ВариантКомплектации", "");
	СтруктураСтроки.Вставить("Добавить", "");
	СтруктураСтроки.Вставить("Удалить", "");
	СтруктураСтроки.Вставить("Зарезервировать", "");
	СтруктураСтроки.Вставить("СнятьРезерв", "");
	СтруктураСтроки.Вставить("ПеренестиРезерв", "");
	СтруктураСтроки.Вставить("ПеренестиРезервНазначение", "");
	СтруктураСтроки.Вставить("ПеренестиВДругойЗаказ", "");
	СтруктураСтроки.Вставить("ПеренестиВДругойЗаказНазначение", "");
	Возврат СтруктураСтроки;
КонецФункции

&НаСервереБезКонтекста
Процедура ТабличныйДокументПриАктивизацииНаСервере()
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура ТабличныйДокументПриАктивизации(Элемент)
	ТабличныйДокументПриАктивизацииНаСервере();
КонецПроцедуры

#КонецОбласти
