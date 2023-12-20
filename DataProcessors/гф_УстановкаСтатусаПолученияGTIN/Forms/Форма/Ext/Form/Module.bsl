﻿ 
&НаКлиенте
Процедура ЗагрузитьИзEcxel(Команда)
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ВыборGTIN", ВыборGTIN);
	Оповещение = Новый ОписаниеОповещения("ВыборВСписокЗавершение", ЭтотОбъект);	
	
	ОткрытьФорму("Отчет.СравнениеСостоянияТовара1С_НК.Форма.ФормаЗагрузки", СтруктураПараметров, ЭтотОбъект, , , ,
		Оповещение, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);

КонецПроцедуры

&НаКлиенте
Процедура ВыборВСписокЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> Неопределено И
		
		Результат.Действие = "ЗаполнениеСпискаОтбора" Тогда
			
			Список.Очистить();
			Для каждого Значение Из Результат.МассивДанных Цикл
				
				Список.Добавить(Значение);
			КонецЦикла;
		    Элементы.Список.Доступность = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ВыборGTIN = 1;
		
КонецПроцедуры 

&НаСервере
Функция НаборСвойств()
	
	НаборыСвойств = УправлениеСвойствамиСлужебный.ПолучитьНаборыСвойствОбъекта(Справочники.Номенклатура.ПустаяСсылка());
	ДоступныеНаборыСвойств = Новый Массив;

	Для каждого Строка Из НаборыСвойств Цикл
		ДоступныеНаборыСвойств.Добавить(Строка.Набор);
	КонецЦикла;
	Возврат ДоступныеНаборыСвойств[0]; 
	
КонецФункции

&НаКлиенте
Процедура СвойствоНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПоказатьДополнительныеСведения"); 
	ПараметрыФормы.Вставить("Набор", НаборСвойств());
	ПараметрыФормы.Вставить("ЗакрыватьПриВыборе", Истина);
    Оповещение = Новый ОписаниеОповещения("ВыборСвойстваЗавершение", ЭтотОбъект);

	ОткрытьФорму("ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения.ФормаВыбора", ПараметрыФормы, ЭтотОбъект, , , ,
		Оповещение, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		
КонецПроцедуры

&НаКлиенте
Процедура ВыборСвойстваЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Свойство = Результат;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаСервере()
	
	//ВидНоменклатурыОбувь = Справочники.ВидыНоменклатуры.НайтиПоНаименованию("Обувь");
	
	Если ВидНоменклатуры.Количество() = 0 Тогда
		//СписокВидовНоменклатуры = Новый Массив;
		//СписокВидовНоменклатуры.Добавить(ВидНоменклатурыОбувь);
		СписокВидовНоменклатуры = _омОбщегоНазначенияВызовСервера.ПолучитьГлобальноеЗначениеМассив("гф_ВидыНоменклатурыДляМаркировки");
	Иначе	
		СписокВидовНоменклатуры = ВидНоменклатуры.ВыгрузитьЗначения();
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Если ЗначениеЗаполнено(ДокументЗагрузки) Тогда
		Запрос.Текст = ТекстЗапросаСПТУ(); 
		Запрос.УстановитьПараметр("ПТУ", ДокументЗагрузки);
		Если ТипЗнч(ДокументЗагрузки) = Тип("ДокументСсылка.ЗаказНаЭмиссиюКодовМаркировкиСУЗ") Тогда
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "ПриобретениеТоваровУслуг", "ЗаказНаЭмиссиюКодовМаркировкиСУЗ");
		КонецЕсли;
	Иначе
		Запрос.Текст = ТекстЗапросаБезПТУ();
	КонецЕсли;
	
	МассивСписка = Список.ВыгрузитьЗначения();
	
	Запрос.УстановитьПараметр("Дата", НачалоДня(ТекущаяДатаСеанса()));
	Запрос.УстановитьПараметр("Артикул", Артикул);
	Запрос.УстановитьПараметр("Значение", ЗначениеСвойства);
	Запрос.УстановитьПараметр("КодТНВЭД", КодТНВЭД);
	
	Запрос.УстановитьПараметр("Свойство", Свойство);
	Запрос.УстановитьПараметр("Сезон", Сезон);
	Запрос.УстановитьПараметр("СтатусНК", СтатусНК);
    Запрос.УстановитьПараметр("Список", МассивСписка);
	Запрос.УстановитьПараметр("Штрихкод", Штрихкод);
	Запрос.УстановитьПараметр("ВидНоменклатуры", СписокВидовНоменклатуры); 
	Запрос.УстановитьПараметр("ОтборПоВидуНоменклатуры", Истина);

	Если Список.Количество() = 0 Тогда
		Запрос.УстановитьПараметр("ОтборПоСпискуGTIN", Ложь);
		Запрос.УстановитьПараметр("ОтборПоСпискуАртикул", Ложь);
	Иначе 
		Запрос.УстановитьПараметр("ОтборПоСпискуGTIN", ?(ВыборGTIN = "1", Истина, Ложь));
		Запрос.УстановитьПараметр("ОтборПоСпискуАртикул", ?(ВыборGTIN = "2", Истина, Ложь));
	КонецЕсли;
	
	Если Свойство <> ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.ПустаяСсылка() Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ПОЛНОЕ СОЕДИНЕНИЕ ВТ_НоменклатураДоп", "ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_НоменклатураДоп");
	КонецЕсли;
		
	РезультатЗапроса = Запрос.Выполнить();

	Объект.Товары.Очистить();
	
	Объект.Товары.Загрузить(РезультатЗапроса.Выгрузить());
	
КонецПроцедуры 

&НаСервере
Функция ТекстЗапросаСПТУ()
	Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПриобретениеТоваровУслугТовары.Номенклатура КАК Номенклатура
		|ПОМЕСТИТЬ ВТ_ПТУ_НеВсе
		|ИЗ
		|	Документ.ПриобретениеТоваровУслуг.Товары КАК ПриобретениеТоваровУслугТовары
		|ГДЕ
		|	ПриобретениеТоваровУслугТовары.Ссылка = &ПТУ
		|	И ВЫБОР
		|			КОГДА &ОтборПоВидуНоменклатуры
		|				ТОГДА ПриобретениеТоваровУслугТовары.Номенклатура.ВидНоменклатуры В (&ВидНоменклатуры)
		|			ИНАЧЕ ИСТИНА
		|		КОНЕЦ
		|	И &УсловиеСезона
		|	И &УсловиеКодТНВЭД
		|	И ВЫБОР
		|			КОГДА &Артикул <> """"
		|				ТОГДА ПриобретениеТоваровУслугТовары.Номенклатура.Артикул = &Артикул
		|			ИНАЧЕ ВЫБОР
		|					КОГДА &ОтборПоСпискуАртикул
		|						ТОГДА ПриобретениеТоваровУслугТовары.Номенклатура.Артикул В (&Список)
		|					ИНАЧЕ ИСТИНА
		|				КОНЕЦ
		|		КОНЕЦ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ШтрихкодыНоменклатуры.Номенклатура КАК Номенклатура,
		|	ШтрихкодыНоменклатуры.Характеристика КАК Характеристика
		|ПОМЕСТИТЬ ВТ_ПТУ
		|ИЗ
		|	РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
		|ГДЕ
		|	ШтрихкодыНоменклатуры.Номенклатура В
		|			(ВЫБРАТЬ
		|				Т.Номенклатура
		|			ИЗ
		|				ВТ_ПТУ_НеВсе КАК Т)
		|	И ВЫБОР
		|			КОГДА &Штрихкод <> """"
		|				ТОГДА ШтрихкодыНоменклатуры.Штрихкод = &Штрихкод
		|			ИНАЧЕ ВЫБОР
		|					КОГДА &ОтборПоСпискуGTIN
		|						ТОГДА ШтрихкодыНоменклатуры.Штрихкод В (&Список)
		|					ИНАЧЕ ИСТИНА
		|				КОНЕЦ
		|		КОНЕЦ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ДополнительныеСведения.Объект КАК Объект
		|ПОМЕСТИТЬ ВТ_НоменклатураДоп
		|ИЗ
		|	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
		|ГДЕ
		|	ВЫБОР
		|			КОГДА &Свойство <> ЗНАЧЕНИЕ(ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения.ПустаяСсылка)
		|				ТОГДА ДополнительныеСведения.Свойство = &Свойство
		|						И ДополнительныеСведения.Значение = &Значение
		|		КОНЕЦ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ПТУ.Номенклатура КАК Номенклатура,
		|	ВТ_ПТУ.Характеристика КАК Характеристика
		|ПОМЕСТИТЬ ВТ_НоменклатураВся
		|ИЗ
		|	ВТ_ПТУ КАК ВТ_ПТУ
		|		ПОЛНОЕ СОЕДИНЕНИЕ ВТ_НоменклатураДоп КАК ВТ_НоменклатураДоп
		|		ПО ВТ_ПТУ.Номенклатура = ВТ_НоменклатураДоп.Объект
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_НоменклатураВся.Номенклатура КАК Номенклатура,
		|	ВТ_НоменклатураВся.Характеристика КАК Характеристика,
		|	СоответствиеОрганизации.Организация КАК Организация
		|ПОМЕСТИТЬ ВТ_НоменклатураОрганизация
		|ИЗ
		|	ВТ_НоменклатураВся КАК ВТ_НоменклатураВся
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.гф_СоответствиеОрганизацииГруппеДступаИСписка КАК СоответствиеОрганизации
		|		ПО ВТ_НоменклатураВся.Номенклатура.ГруппаДоступа = СоответствиеОрганизации.ГруппаДоступа
		|			И ВТ_НоменклатураВся.Номенклатура.Родитель = СоответствиеОрганизации.ГруппаСписка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	гф_СтатусыGTINСрезПоследних.Статус КАК Статус,
		|	гф_СтатусыGTINСрезПоследних.Номенклатура КАК Номенклатура,
		|	гф_СтатусыGTINСрезПоследних.Характеристика КАК Характеристика,
		|	гф_СтатусыGTINСрезПоследних.GTIN КАК GTIN
		|ПОМЕСТИТЬ ВТ_СтатусыGTIN
		|ИЗ
		|	РегистрСведений.гф_СтатусыGTIN.СрезПоследних(
		|			&Дата,
		|			(Номенклатура, Характеристика) В
		|				(ВЫБРАТЬ
		|					Т.Номенклатура,
		|					Т.Характеристика
		|				ИЗ
		|					ВТ_НоменклатураОрганизация КАК Т)) КАК гф_СтатусыGTINСрезПоследних
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ВТ_НоменклатураОрганизация.Номенклатура КАК Номенклатура,
		|	ВТ_НоменклатураОрганизация.Номенклатура.Артикул КАК Артикул,
		|	ВТ_НоменклатураОрганизация.Организация КАК Организация,
		|	ШтрихкодыНоменклатуры.Характеристика КАК Характеристика,
		|	ШтрихкодыНоменклатуры.Штрихкод КАК Штрихкод,
		|	ВТ_СтатусыGTIN.Статус КАК СтатусGTIN
		|ИЗ
		|	ВТ_НоменклатураОрганизация КАК ВТ_НоменклатураОрганизация
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
		|			ЛЕВОЕ СОЕДИНЕНИЕ ВТ_СтатусыGTIN КАК ВТ_СтатусыGTIN
		|			ПО ШтрихкодыНоменклатуры.Номенклатура = ВТ_СтатусыGTIN.Номенклатура
		|				И ШтрихкодыНоменклатуры.Характеристика = ВТ_СтатусыGTIN.Характеристика
		|		ПО ВТ_НоменклатураОрганизация.Номенклатура = ШтрихкодыНоменклатуры.Номенклатура
		|			И ВТ_НоменклатураОрганизация.Характеристика = ШтрихкодыНоменклатуры.Характеристика
		|ГДЕ
		|	ВЫБОР
		|			КОГДА &ОтборПоСпискуGTIN
		|				ТОГДА ШтрихкодыНоменклатуры.Штрихкод В (&Список)
		|			ИНАЧЕ ИСТИНА
		|		КОНЕЦ
		|	И ШтрихкодыНоменклатуры.Штрихкод <> """"
		|
		|УПОРЯДОЧИТЬ ПО
		|	Артикул";
	
	Если ТипЗнч(ДокументЗагрузки) = Тип("ДокументСсылка.ЗаказНаЭмиссиюКодовМаркировкиСУЗ") Тогда
		Текст = СтрЗаменить(Текст, "ПриобретениеТоваровУслуг", "ЗаказНаЭмиссиюКодовМаркировкиСУЗ");
	КонецЕсли; 
	
	Если Штрихкод = "" ИЛИ (Список.Количество() = 0 И ВыборGTIN <> "1") Тогда
		Текст = СтрЗаменить(Текст, "И ВТ_ПТУ.Характеристика = ВТ_ОграниченияДоп2.Характеристика", "");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Сезон) Тогда
		Текст = СтрЗаменить(Текст, "&УсловиеСезона", "Номенклатура.КоллекцияНоменклатуры = &Сезон");
	Иначе
		Текст = СтрЗаменить(Текст, "И &УсловиеСезона", "");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(КодТНВЭД) Тогда
		Текст = СтрЗаменить(Текст, "&УсловиеКодТНВЭД", "Номенклатура.КодТНВЭД = &КодТНВЭД");
	Иначе
		Текст = СтрЗаменить(Текст, "И &УсловиеКодТНВЭД", "");
	КонецЕсли;
	
	Возврат Текст;

КонецФункции

&НаСервере
Функция ТекстЗапросаБезПТУ()
	
	Текст = 
		"ВЫБРАТЬ
		|	Номенклатура.Ссылка КАК Ссылка
		|ПОМЕСТИТЬ ВТ_НоменклатураОсн
		|ИЗ
		|	Справочник.Номенклатура КАК Номенклатура
		|ГДЕ
		|	ВЫБОР
		|			КОГДА &ОтборПоВидуНоменклатуры
		|				ТОГДА Номенклатура.ВидНоменклатуры В (&ВидНоменклатуры)
		|			ИНАЧЕ ИСТИНА
		|		КОНЕЦ
		|	И &УсловиеСезона
		|	И &УсловиеКодТНВЭД
		|	И ВЫБОР
		|			КОГДА &Артикул <> """"
		|				ТОГДА Номенклатура.Артикул = &Артикул
		|			ИНАЧЕ ВЫБОР
		|					КОГДА &ОтборПоСпискуАртикул
		|						ТОГДА Номенклатура.Артикул В (&Список)
		|					ИНАЧЕ ИСТИНА
		|				КОНЕЦ
		|		КОНЕЦ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ДополнительныеСведения.Объект КАК Объект
		|ПОМЕСТИТЬ ВТ_НоменклатураДоп
		|ИЗ
		|	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
		|ГДЕ
		|	ВЫБОР
		|			КОГДА &Свойство <> ЗНАЧЕНИЕ(ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения.ПустаяСсылка)
		|				ТОГДА ДополнительныеСведения.Свойство = &Свойство
		|						И ДополнительныеСведения.Значение = &Значение
		|		КОНЕЦ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ШтрихкодыНоменклатуры.Номенклатура КАК Номенклатура,
		|	ШтрихкодыНоменклатуры.Характеристика КАК Характеристика
		|ПОМЕСТИТЬ ВТ_НоменклатураШтрих
		|ИЗ
		|	РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
		|ГДЕ
		|	ВЫБОР
		|			КОГДА &Штрихкод <> """"
		|				ТОГДА ШтрихкодыНоменклатуры.Штрихкод = &Штрихкод
		|			ИНАЧЕ ВЫБОР
		|					КОГДА &ОтборПоСпискуGTIN
		|						ТОГДА ШтрихкодыНоменклатуры.Штрихкод В (&Список)
		|				КОНЕЦ
		|		КОНЕЦ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВЫБОР
		|		КОГДА ВТ_НоменклатураОсн.Ссылка <> ЗНАЧЕНИЕ(Справочник.Номенклатура.пустаяСсылка)
		|			ТОГДА ВТ_НоменклатураОсн.Ссылка
		|		ИНАЧЕ ВЫБОР
		|				КОГДА ВТ_НоменклатураДоп.Объект <> ЗНАЧЕНИЕ(Справочник.Номенклатура.пустаяСсылка)
		|					ТОГДА ВТ_НоменклатураДоп.Объект
		|			КОНЕЦ
		|	КОНЕЦ КАК Номенклатура
		|ПОМЕСТИТЬ ВТ_ОграниченияДоп
		|ИЗ
		|	ВТ_НоменклатураОсн КАК ВТ_НоменклатураОсн
		|		ПОЛНОЕ СОЕДИНЕНИЕ ВТ_НоменклатураДоп КАК ВТ_НоменклатураДоп
		|		ПО ВТ_НоменклатураОсн.Ссылка = ВТ_НоменклатураДоп.Объект
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВЫБОР
		|		КОГДА ВТ_ОграниченияДоп.Номенклатура <> ЗНАЧЕНИЕ(Справочник.Номенклатура.пустаяСсылка)
		|			ТОГДА ВТ_ОграниченияДоп.Номенклатура
		|		ИНАЧЕ ВЫБОР
		|				КОГДА ВТ_НоменклатураШтрих.Номенклатура <> ЗНАЧЕНИЕ(Справочник.Номенклатура.пустаяСсылка)
		|					ТОГДА ВТ_НоменклатураШтрих.Номенклатура
		|			КОНЕЦ
		|	КОНЕЦ КАК Номенклатура,
		|	ВЫБОР
		|		КОГДА ВТ_НоменклатураШтрих.Характеристика <> ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.Пустаяссылка)
		|			ТОГДА ВТ_НоменклатураШтрих.Характеристика
		|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.Пустаяссылка)
		|	КОНЕЦ КАК Характеристика
		|ПОМЕСТИТЬ ВТ_НоменклатураВся
		|ИЗ
		|	ВТ_ОграниченияДоп КАК ВТ_ОграниченияДоп
		|		ПОЛНОЕ СОЕДИНЕНИЕ ВТ_НоменклатураШтрих КАК ВТ_НоменклатураШтрих
		|		ПО ВТ_ОграниченияДоп.Номенклатура = ВТ_НоменклатураШтрих.Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_НоменклатураВся.Номенклатура КАК Номенклатура,
		|	ВТ_НоменклатураВся.Характеристика КАК Характеристика,
		|	СоответствиеОрганизации.Организация КАК Организация
		|ПОМЕСТИТЬ ВТ_НоменклатураОрганизация
		|ИЗ
		|	ВТ_НоменклатураВся КАК ВТ_НоменклатураВся
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.гф_СоответствиеОрганизацииГруппеДступаИСписка КАК СоответствиеОрганизации
		|		ПО ВТ_НоменклатураВся.Номенклатура.ГруппаДоступа = СоответствиеОрганизации.ГруппаДоступа
		|			И ВТ_НоменклатураВся.Номенклатура.Родитель = СоответствиеОрганизации.ГруппаСписка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	гф_СтатусыGTINСрезПоследних.Статус КАК Статус,
		|	гф_СтатусыGTINСрезПоследних.Номенклатура КАК Номенклатура,
		|	гф_СтатусыGTINСрезПоследних.Характеристика КАК Характеристика,
		|	гф_СтатусыGTINСрезПоследних.GTIN КАК GTIN
		|ПОМЕСТИТЬ ВТ_СтатусыGTIN
		|ИЗ
		|	РегистрСведений.гф_СтатусыGTIN.СрезПоследних(
		|			&Дата,
		|			(Номенклатура, Характеристика) В
		|				(ВЫБРАТЬ
		|					Т.Номенклатура,
		|					Т.Характеристика
		|				ИЗ
		|					ВТ_НоменклатураОрганизация КАК Т)) КАК гф_СтатусыGTINСрезПоследних
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ВТ_НоменклатураОрганизация.Номенклатура КАК Номенклатура,
		|	ВТ_НоменклатураОрганизация.Номенклатура.Артикул КАК Артикул,
		|	ВТ_НоменклатураОрганизация.Организация КАК Организация,
		|	ШтрихкодыНоменклатуры.Характеристика КАК Характеристика,
		|	ШтрихкодыНоменклатуры.Штрихкод КАК Штрихкод,
		|	ВТ_СтатусыGTIN.Статус КАК СтатусGTIN
		|ИЗ
		|	ВТ_НоменклатураОрганизация КАК ВТ_НоменклатураОрганизация
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
		|			ЛЕВОЕ СОЕДИНЕНИЕ ВТ_СтатусыGTIN КАК ВТ_СтатусыGTIN
		|			ПО ШтрихкодыНоменклатуры.Номенклатура = ВТ_СтатусыGTIN.Номенклатура
		|				И ШтрихкодыНоменклатуры.Характеристика = ВТ_СтатусыGTIN.Характеристика
		|		ПО ВТ_НоменклатураОрганизация.Номенклатура = ШтрихкодыНоменклатуры.Номенклатура 
		|			И ВТ_НоменклатураОрганизация.Характеристика = ШтрихкодыНоменклатуры.Характеристика
		|ГДЕ
		|	ВЫБОР
		|			КОГДА &ОтборПоСпискуGTIN
		|				ТОГДА ШтрихкодыНоменклатуры.Штрихкод В (&Список)
		|			ИНАЧЕ ИСТИНА
		|		КОНЕЦ
		|	И ШтрихкодыНоменклатуры.Штрихкод <> """"
		|
		|УПОРЯДОЧИТЬ ПО
		|	Артикул";
	
	Если Штрихкод = "" ИЛИ (Список.Количество() = 0 И ВыборGTIN = "1") Тогда
		Текст = СтрЗаменить(Текст, "И ВТ_НоменклатураОрганизация.Характеристика = ШтрихкодыНоменклатуры.Характеристика", "");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Сезон) Тогда
		Текст = СтрЗаменить(Текст, "&УсловиеСезона", "Номенклатура.КоллекцияНоменклатуры = &Сезон");
	Иначе
		Текст = СтрЗаменить(Текст, "И &УсловиеСезона", "");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(КодТНВЭД) Тогда
		Текст = СтрЗаменить(Текст, "&УсловиеКодТНВЭД", "Номенклатура.КодТНВЭД = &КодТНВЭД");
	Иначе
		Текст = СтрЗаменить(Текст, "И &УсловиеКодТНВЭД", "");
	КонецЕсли;
	Если Штрихкод <> "" ИЛИ (Список.Количество() > 0 И ВыборGTIN = "1") Тогда
		Текст = СтрЗаменить(Текст, "ПОЛНОЕ СОЕДИНЕНИЕ ВТ_НоменклатураШтрих", "ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_НоменклатураШтрих");
	КонецЕсли;

	Возврат Текст;
	
КонецФункции

&НаКлиенте
Процедура Заполнить(Команда)
	ЗаполнитьНаСервере();
КонецПроцедуры

&НаСервере
Процедура УстановитьСтатусGTINНаСервере(ТолькоНовые = Ложь)
	
	Если ТолькоНовые Тогда
		ТаблицаОбработки = Объект.Товары.НайтиСтроки(Новый Структура("СтатусGTIN", ""));
	Иначе
		ТаблицаОбработки = Объект.Товары.Выгрузить();
	КонецЕсли;
	
	СтатсусПолучен = Перечисления.гф_СтатусыGTIN_В_НК.GTINПолучен;
	ДатаСтатуса = ТекущаяДатаСеанса();
	
	Для каждого Строка Из ТаблицаОбработки Цикл
		
		Если Не ЗначениеЗаполнено(Строка.Организация) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("По строке " 
			+ Строка.НомерСтроки + " не будет изменен статус, так как не заполнена Организация");
			Продолжить;
		КонецЕсли;
		
		НоваяЗапись = РегистрыСведений.гф_СтатусыGTIN.СоздатьМенеджерЗаписи();
		НоваяЗапись.Период = ДатаСтатуса;
		НоваяЗапись.GTIN = Строка.Штрихкод;
		НоваяЗапись.Номенклатура = Строка.Номенклатура;
		НоваяЗапись.Характеристика = Строка.Характеристика;
		НоваяЗапись.Организация = Строка.Организация;
		
		Если Строка.СтатусGTIN <> СтатсусПолучен Тогда
			НоваяЗапись.Статус = СтатсусПолучен;		
			НоваяЗапись.Записать();
			ОбновлениеСтатусаШтрихкода(Строка.Штрихкод, СтатсусПолучен);
		КонецЕсли; 
	
	КонецЦикла;	
	
	ОбновитьТЧТовары();

КонецПроцедуры

&НаСервере
Процедура ОбновлениеСтатусаШтрихкода(НайденныйШтрихкод, СтатсусПолучен)
				
	ТекЗапись = РегистрыСведений.ШтрихкодыНоменклатуры.СоздатьМенеджерЗаписи();
	ТекЗапись.Штрихкод = НайденныйШтрихкод;
	ТекЗапись.Прочитать();
	
	Если ТекЗапись.Выбран() Тогда 
		ТекЗапись.гф_СостояниеВыгрузкиНоменклатуры = СтатсусПолучен;
		ТекЗапись.Записать();
	
	КонецЕсли;	
	 
КонецПроцедуры

&НаКлиенте
Процедура УстановитьСтатусGTIN(Команда)
	
	ТекстВопроса = НСтр("ru='Будет установлен статус GTIN получен. Продолжить?'");
	ДопПараметры = Новый Структура() ;
	Оповещение = Новый ОписаниеОповещения("гф_ВопросУстановитьСтатусЗавершение", ЭтотОбъект, ДопПараметры);
	ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);

КонецПроцедуры

&НаКлиенте
Процедура гф_ВопросУстановитьСтатусЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = КодВозвратаДиалога.Да Тогда
		// ++ ДомнышеваКР_26_05_2023
		АдресТоваровКПовторнойЗагрузки = ПолучитьТЧТовары();
		Если АдресТоваровКПовторнойЗагрузки = Неопределено Тогда
			УстановитьСтатусGTINНаСервере();
		Иначе
			
			Оповещение = Новый ОписаниеОповещения("ПослеПринятияРешения", ЭтотОбъект, ЭтотОбъект);
			ПараметрыОткрытия = Новый Структура;
			ПараметрыОткрытия.Вставить("Товары", АдресТоваровКПовторнойЗагрузки);
			
			ОткрытьФорму("Обработка.гф_УстановкаСтатусаПолученияGTIN.Форма.ФормаНайденныйСтатус", ПараметрыОткрытия,
			ЭтотОбъект, , , , Оповещение, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);				
			
		КонецЕсли;
		// -- ДомнышеваКР_26_05_2023
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПослеПринятияРешения(Результат, ЭтотОбъект) Экспорт
    // ++ ДомнышеваКР_26_05_2023
	Если Результат = "Нет" Тогда		
		УстановитьСтатусGTINНаСервере(Истина);
	Иначе
		УстановитьСтатусGTINНаСервере();
	КонецЕсли;
    // -- ДомнышеваКР_26_05_2023
КонецПроцедуры

&НаСервере
Процедура ОбновитьТЧТовары()

	МассивШтрихкодов = Объект.Товары.Выгрузить(,"Штрихкод");
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	гф_СтатусыGTINСрезПоследних.Номенклатура КАК Номенклатура,
		|	гф_СтатусыGTINСрезПоследних.Номенклатура.Артикул КАК Артикул,
		|	гф_СтатусыGTINСрезПоследних.Характеристика КАК Характеристика,
		|	гф_СтатусыGTINСрезПоследних.GTIN КАК Штрихкод,
		|	гф_СтатусыGTINСрезПоследних.Статус КАК СтатусGTIN,
		|	гф_СтатусыGTINСрезПоследних.Организация КАК Организация
		|ИЗ
		|	РегистрСведений.гф_СтатусыGTIN.СрезПоследних КАК гф_СтатусыGTINСрезПоследних
		|ГДЕ
		|	гф_СтатусыGTINСрезПоследних.GTIN В(&МассивШтрихкодов)";
	
	Запрос.УстановитьПараметр("МассивШтрихкодов", МассивШтрихкодов);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	Объект.Товары.Очистить();

	Пока Выборка.Следующий() Цикл
		
		НоваяСтрока = Объект.Товары.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Выборка);
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТЧТовары()
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811edf965bf211028
	// ++ ДомнышеваКР_26_05_2023	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТЗ.Номенклатура КАК Номенклатура,
		|	ТЗ.Артикул КАК Артикул,
		|	ТЗ.Характеристика КАК Характеристика,
		|	ТЗ.Штрихкод КАК Штрихкод,
		|	ТЗ.СтатусGTIN КАК СтатусGTIN,
		|	ТЗ.Организация КАК Организация
		|   Поместить ВТ_ТЗ
		|ИЗ
		|	&ТЗ КАК ТЗ
		|ГДЕ
		|	ТЗ.СтатусGTIN <> """"
		|
		|;
		|
		|//////////////////////////////////////
		|
		|ВЫБРАТЬ
		|	ВТ_ТЗ.Номенклатура КАК Номенклатура,
		|	ВТ_ТЗ.Артикул КАК Артикул,
		|	ВТ_ТЗ.Характеристика КАК Характеристика,
		|	ВТ_ТЗ.Штрихкод КАК Штрихкод,
		|	ВТ_ТЗ.СтатусGTIN КАК СтатусGTIN,
		|	ВТ_ТЗ.Организация КАК Организация
		|ИЗ
		|	ВТ_ТЗ КАК ВТ_ТЗ
		|";
	
	Запрос.УстановитьПараметр("ТЗ", Объект.Товары.Выгрузить());
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	Иначе	
		
		ТоварыКПовторнойЗагрузке = РезультатЗапроса.Выгрузить();
		АдресТоваров = ПоместитьВоВременноеХранилище(ТоварыКПовторнойЗагрузке, Новый УникальныйИдентификатор);
		Возврат АдресТоваров;
	КонецЕсли; 
	// -- ДомнышеваКР_26_05_2023
КонецФункции

&НаКлиенте
Процедура ЗаполнитьОрганизацию(Команда)
	// #wortmann { 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee9f2215e254b7
	// Галфинд_Домнышева 2023/12/20
	ПараметрыФормы = Новый Структура;
	ДополнительныеПараметры = Новый Структура();
	Оповещение = Новый ОписаниеОповещения("ПослеВыбораОрганизации", ЭтотОбъект, ДополнительныеПараметры);
	ОткрытьФорму("Справочник.Организации.Форма.ФормаВыбора", ПараметрыФормы, ЭтотОбъект, , , , Оповещение,
	РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	// } #wortmann
КонецПроцедуры

&НаКлиенте
Процедура ПослеВыбораОрганизации(Результат, ДополнительныеПараметры) Экспорт
	// #wortmann { 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee9f2215e254b7
	// Галфинд_Домнышева 2023/12/20
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
    ЗаполнитьОрганизациюПустыеСтроки(Результат);
    // } #wortmann

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОрганизациюПустыеСтроки(Организация)
	// #wortmann { 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee9f2215e254b7
	// Галфинд_Домнышева 2023/12/20
	Отбор = Новый Структура();
	Отбор.Вставить("Организация", Справочники.Организации.ПустаяСсылка());
	МассивПустыхСтрок = Объект.Товары.НайтиСтроки(Отбор);
	Для каждого Строка Из МассивПустыхСтрок Цикл
		Строка.Организация = Организация;
	КонецЦикла;
	// } #wortmann

КонецПроцедуры

