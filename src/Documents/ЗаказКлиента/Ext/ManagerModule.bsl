﻿
&ИзменениеИКонтроль("ДанныеДокументаДляПроведения")
Функция гф_ДанныеДокументаДляПроведения(Документ, Регистры, ДопПараметры)

	Если ДопПараметры = Неопределено Тогда
		ДопПараметры = ПроведениеДокументов.ДопПараметрыИнициализироватьДанныеДокументаДляПроведения();
	КонецЕсли;

	Запрос			= Новый Запрос;
	ТекстыЗапроса	= Новый СписокЗначений;

	Если Не ДопПараметры.ПолучитьТекстыЗапроса Тогда
		////////////////////////////////////////////////////////////////////////////
		// Создадим запрос инициализации движений

		ЗаполнитьПараметрыИнициализации(Запрос, Документ);

		////////////////////////////////////////////////////////////////////////////
		// Сформируем текст запроса
		СформироватьСуммыДокументаВВалютахУчета(Запрос, ТекстыЗапроса, Регистры);

		ТекстЗапросаТаблицаЗаказыКлиентов(Запрос, ТекстыЗапроса, Регистры);
		ТекстЗапросаТаблицаРеестрДокументов(Запрос, ТекстыЗапроса, Регистры);
		ТекстЗапросаБонусныеБаллы(Запрос, ТекстыЗапроса, Регистры);
	КонецЕсли;

	ОтразитьРаспределениеЗапасовДвижения(Запрос, ТекстыЗапроса, Регистры);
	ДобавитьТекстыОтраженияВзаиморасчетов(Запрос, ТекстыЗапроса, Регистры);
	#Удаление
	ОтразитьРезерв(Запрос, ТекстыЗапроса, Регистры);
	ЗапланироватьОтгрузкуТоваров(Запрос, ТекстыЗапроса, Регистры);
	#КонецУдаления
    #Вставка
	// ++ Галфинд ВолковЕВ 16.01.2023
	Если Документ.гф_ОтгрузкаПеремещением Тогда
		ОтразитьРезервПеремещениеПоПолучателю(Запрос, ТекстыЗапроса, Регистры, Документ);
		ЗапланироватьОтгрузкуТоваровПеремещениеПоПолучателя(Запрос, ТекстыЗапроса, Регистры);
	Иначе
		ОтразитьРезерв(Запрос, ТекстыЗапроса, Регистры);
		ЗапланироватьОтгрузкуТоваров(Запрос, ТекстыЗапроса, Регистры);
	КонецЕсли;
	// -- Галфинд ВолковЕВ 16.01.2023
	#КонецВставки

	////////////////////////////////////////////////////////////////////////////
	// Получим таблицы для движений

	Возврат ПроведениеДокументов.ИнициализироватьДанныеДокументаДляПроведения(Запрос, ТекстыЗапроса, ДопПараметры);

КонецФункции

Процедура ОтразитьРезервПеремещениеПоПолучателю(Запрос, ТекстыЗапроса, Регистры, Документ)
	
	ТекстЗапросаДанныхДокумента = 
	"ВЫБРАТЬ
	|	ТоварыДокумента.Ссылка				КАК Ссылка,
	|	ДанныеШапки.Дата					КАК Период,
	|	ТоварыДокумента.Ссылка				КАК Заказ,
	|	НЕОПРЕДЕЛЕНО						КАК Накладная,
	|	ЛОЖЬ								КАК Исправление,
	|	НЕОПРЕДЕЛЕНО						КАК ИсправляемыйДокумент,
	//|	ДанныеШапки.Партнер					КАК Получатель,
	|	ДанныеШапки.гф_СкладПолучатель		КАК Получатель,
	|	ТоварыДокумента.Склад				КАК Склад,
	|	ТоварыДокумента.Номенклатура		КАК Номенклатура,
	|	ТоварыДокумента.Характеристика		КАК Характеристика,
	|	ВЫБОР
	|		КОГДА ТоварыДокумента.Обособленно
	|			ТОГДА ДанныеШапки.Назначение
	|		ИНАЧЕ &НазначениеПоУмолчанию
	|	КОНЕЦ								КАК Назначение,
	|	ТоварыДокумента.Серия				КАК Серия,
	|	ТоварыДокумента.СтатусУказанияСерий	КАК СтатусУказанияСерий,
	|	ТоварыДокумента.Количество			КАК Количество,
	|	ЛОЖЬ								КАК СверхЗаказа,
	|	ТоварыДокумента.Отменено			КАК Отменено,
	|	ЛОЖЬ								КАК ЭтоНакладная,
	|	ИСТИНА								КАК ОтгрузкаПоЗаказу
	|ИЗ
	|	Документ.ЗаказКлиента.Товары КАК ТоварыДокумента
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК ДанныеШапки
	|		ПО ТоварыДокумента.Ссылка = ДанныеШапки.Ссылка
	|
	|ГДЕ
	|	ТоварыДокумента.Ссылка В(&Ссылка)
	|	И &ИспользоватьРасширенныеВозможностиЗаказа
	|	И ДанныеШапки.ХозяйственнаяОперация <> ЗНАЧЕНИЕ(Перечисление.ХозяйственныеОперации.РеализацияКлиентуРеглУчет)
	|	И (ТоварыДокумента.ВариантОбеспечения = ЗНАЧЕНИЕ(Перечисление.ВариантыОбеспечения.СоСклада)
	|		ИЛИ ТоварыДокумента.ВариантОбеспечения = ЗНАЧЕНИЕ(Перечисление.ВариантыОбеспечения.Отгрузить)
	|			И ДанныеШапки.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыЗаказовКлиентов.НеСогласован))
	|	И ТоварыДокумента.Количество <> 0";
	
	ИспользоватьРасширенныеВозможностиЗаказа = ?(ПолучитьФункциональнуюОпцию("ИспользоватьРасширенныеВозможностиЗаказаКлиента"),
												"ИСТИНА",
												"ЛОЖЬ");
	
	ТекстЗапросаДанныхДокумента = СтрЗаменить(ТекстЗапросаДанныхДокумента,
												"&НазначениеПоУмолчанию",
												"ЗНАЧЕНИЕ(Справочник.Назначения.ПустаяСсылка)");
	ТекстЗапросаДанныхДокумента = СтрЗаменить(ТекстЗапросаДанныхДокумента,
												"&ИспользоватьРасширенныеВозможностиЗаказа",
												ИспользоватьРасширенныеВозможностиЗаказа);
	
	СкладыСервер.ОтразитьРезерв(Запрос, ТекстыЗапроса, Регистры, ТекстЗапросаДанныхДокумента);
	
КонецПроцедуры

Процедура ЗапланироватьОтгрузкуТоваровПеремещениеПоПолучателя(Запрос, ТекстыЗапроса, Регистры)
	
	ТекстЗапросаДанныхДокумента = 
	"ВЫБРАТЬ
	|	ТоварыДокумента.Ссылка				КАК Ссылка,
	|	ТоварыДокумента.ДатаОтгрузки		КАК Период,
	|	ТоварыДокумента.Ссылка				КАК Заказ,
	|	НЕОПРЕДЕЛЕНО						КАК Накладная,
	|	ЛОЖЬ								КАК Исправление,
	|	НЕОПРЕДЕЛЕНО						КАК ИсправляемыйДокумент,
	//|	ДанныеШапки.Партнер					КАК Получатель,
	|	ДанныеШапки.гф_СкладПолучатель		КАК Получатель,
	|	ТоварыДокумента.Склад				КАК Склад,
	|	ТоварыДокумента.Номенклатура		КАК Номенклатура,
	|	ТоварыДокумента.Характеристика		КАК Характеристика,
	|	ВЫБОР
	|		КОГДА ТоварыДокумента.Обособленно
	|			ТОГДА ДанныеШапки.Назначение
	|		ИНАЧЕ &НазначениеПоУмолчанию
	|	КОНЕЦ								КАК Назначение,
	|	ТоварыДокумента.Серия				КАК Серия,
	|	ТоварыДокумента.СтатусУказанияСерий	КАК СтатусУказанияСерий,
	|	ТоварыДокумента.Количество			КАК Количество,
	|	ЛОЖЬ								КАК СверхЗаказа,
	|	ТоварыДокумента.Отменено			КАК Отменено,
	|	ЛОЖЬ								КАК ЭтоНакладная,
	|	ИСТИНА								КАК ОтгрузкаПоЗаказу
	|ИЗ
	|	Документ.ЗаказКлиента.Товары КАК ТоварыДокумента
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК ДанныеШапки
	|		ПО ТоварыДокумента.Ссылка = ДанныеШапки.Ссылка
	|
	|ГДЕ
	|	ТоварыДокумента.Ссылка В(&Ссылка)
	|	И &ИспользоватьРасширенныеВозможностиЗаказа
	|	И ДанныеШапки.Статус <> ЗНАЧЕНИЕ(Перечисление.СтатусыЗаказовКлиентов.НеСогласован)
	|	И ДанныеШапки.ХозяйственнаяОперация <> ЗНАЧЕНИЕ(Перечисление.ХозяйственныеОперации.РеализацияКлиентуРеглУчет)
	|	И ТоварыДокумента.ВариантОбеспечения = ЗНАЧЕНИЕ(Перечисление.ВариантыОбеспечения.Отгрузить)
	|	И ТоварыДокумента.Количество <> 0";
	
	ИспользоватьРасширенныеВозможностиЗаказа = ?(ПолучитьФункциональнуюОпцию("ИспользоватьРасширенныеВозможностиЗаказаКлиента"),
												"ИСТИНА",
												"ЛОЖЬ");
	
	ТекстЗапросаДанныхДокумента = СтрЗаменить(ТекстЗапросаДанныхДокумента,
												"&НазначениеПоУмолчанию",
												"ЗНАЧЕНИЕ(Справочник.Назначения.ПустаяСсылка)");
	ТекстЗапросаДанныхДокумента = СтрЗаменить(ТекстЗапросаДанныхДокумента,
												"&ИспользоватьРасширенныеВозможностиЗаказа",
												ИспользоватьРасширенныеВозможностиЗаказа);
	
	СкладыСервер.ЗапланироватьОтгрузкуТоваров(Запрос, ТекстыЗапроса, Регистры, ТекстЗапросаДанныхДокумента);
	
КонецПроцедуры
