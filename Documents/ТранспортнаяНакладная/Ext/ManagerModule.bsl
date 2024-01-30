﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

&ИзменениеИКонтроль("Печать")
Процедура гф_Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода)

	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ТранспортнаяНакладная") Тогда
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		"ТранспортнаяНакладная", НСтр("ru = 'Транспортная накладная';
		|en = 'Consignment note'"),
		СформироватьПечатнуюФормуТранспортнойНакладной(МассивОбъектов, ОбъектыПечати));
	КонецЕсли;

	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ТТН") Тогда
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		"ТТН",
		НСтр("ru = 'Товарно-транспортная накладная';
		|en = 'Waybill'"),
		СформироватьПечатнуюФормуТТН(МассивОбъектов, ОбъектыПечати, ПараметрыПечати));	
	КонецЕсли;
	#Вставка
	//++ ЕсиповАВ
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "СМР") Тогда
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		"СМР",
		НСтр("ru = 'Накладная CMR';
		|en = 'CMR'"),
		СформироватьПечатнуюФормуСМР(МассивОбъектов, ОбъектыПечати, ПараметрыПечати));	
	КонецЕсли;
	//-- ЕсиповАВ
	#КонецВставки

	ФормированиеПечатныхФорм.ЗаполнитьПараметрыОтправки(ПараметрыВывода.ПараметрыОтправки, МассивОбъектов, КоллекцияПечатныхФорм);

КонецПроцедуры

Функция СформироватьПечатнуюФормуСМР(МассивОбъектов, ОбъектыПечати, ПараметрыПечати) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.РазмерКолонтитулаСверху = 0;
	ТабличныйДокумент.РазмерКолонтитулаСнизу = 0;
	ТабличныйДокумент.АвтоМасштаб = Истина;
	ТабличныйДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
	
	МакетОбработки = ПолучитьМакет("гф_CMR");
	ОбластьШапка = МакетОбработки.ПолучитьОбласть("Шапка");
	ОбластьСтрока = МакетОбработки.ПолучитьОбласть("Строка");
	ОбластьПодвал = МакетОбработки.ПолучитьОбласть("Подвал");
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	РеализацияТоваровУслуг.Ссылка КАК Ссылка,
	|	РеализацияТоваровУслуг.АдресДоставки КАК АдресДоставки,
	|	РеализацияТоваровУслуг.Валюта КАК Валюта,
	|	РеализацияТоваровУслуг.Грузоотправитель КАК Грузоотправитель,
	|	РеализацияТоваровУслуг.Грузополучатель КАК Грузополучатель,
	|	РеализацияТоваровУслуг.Организация КАК Организация,
	|	РеализацияТоваровУслуг.СуммаВзаиморасчетов КАК СуммаВзаиморасчетов,
	|	РеализацияТоваровУслуг.гф_ТоварыВКоробах.(
	|		Ссылка КАК Ссылка,
	|		НомерСтроки КАК НомерСтроки,
	|		УпаковочныйЛист КАК УпаковочныйЛист,
	|		Артикул КАК Артикул,
	|		КоличествоПар КАК КоличествоПар,
	|		Коэффициент КАК Коэффициент,
	|		ЦенаКороба КАК ЦенаКороба,
	|		НДС КАК НДС
	|	) КАК гф_ТоварыВКоробах,
	|	РеализацияТоваровУслуг.ПеревозчикПартнер КАК ПеревозчикПартнер
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	|ГДЕ
	|	РеализацияТоваровУслуг.Ссылка = &Ссылка";
	Запрос.Параметры.Вставить("Ссылка",МассивОбъектов[0].Ссылка);
	Таб = Запрос.Выполнить().Выгрузить();
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ТранспортнаяНакладная.ДокументыОснования.(
	|		ДокументОснование КАК ДокументОснование
	|	) КАК ДокументыОснования,
	|	ТранспортнаяНакладная.Грузоотправитель КАК Грузоотправитель,
	|	ТранспортнаяНакладная.Грузополучатель КАК Грузополучатель,
	|	ТранспортнаяНакладная.Организация КАК Организация,
	|	ТранспортнаяНакладная.МассаБрутто КАК МассаБрутто,
	|	ТранспортнаяНакладная.Дата КАК Дата
	|ИЗ
	|	Документ.ТранспортнаяНакладная КАК ТранспортнаяНакладная
	|ГДЕ
	|	ТранспортнаяНакладная.ДокументыОснования.ДокументОснование.Ссылка = &Ссылка";
	Запрос.Параметры.Вставить("Ссылка",МассивОбъектов[0].Ссылка);
	ТабНакладная = Запрос.Выполнить().Выгрузить();
	
	//Заполнение области Шапка
	ОбластьШапка.Параметры.НаименованиеОрганизации    = ТабНакладная[0].Грузоотправитель.Наименование;
	ОбластьШапка.Параметры.АдресОрганизации           = ТабНакладная[0].Организация.СтранаРегистрации.НаименованиеПолное;
	ОбластьШапка.Параметры.ПолучательНаименование     = ТабНакладная[0].Грузополучатель.НаименованиеПолное;
	ОбластьШапка.Параметры.ПолучательСтрана           = ТабНакладная[0].Организация.СтранаРегистрации.НаименованиеПолное;
	ОбластьШапка.Параметры.ПолучательАдрес            = Таб[0].АдресДоставки;
	ОбластьШапка.Параметры.ПеревозчикНаименование     = Таб[0].ПеревозчикПартнер.Наименование;
	//ОбластьШапка.Параметры.АдресПогрузкиГруза         = ;
	//ОбластьШапка.Параметры.СтранаПогрузкиГруза        = ;
	ОбластьШапка.Параметры.ДатаПогрузкиГруза          = ТабНакладная[0].Дата;
	//ОбластьШапка.Параметры.НаименованиеНомерДокумента = ;
	ТабличныйДокумент.Вывести(ОбластьШапка);
	//
	
	//Заполнение области Строка
	//Кол = 0;
	//Для Каждого Стр Из Таб[0].Товары Цикл
	//	Кол = Кол + Таб[0].Товары[0].Количество;
	//КонецЦикла;	
	//ОбластьСтрока.Параметры.ЗнакиНомера    = ;
	ОбластьСтрока.Параметры.КоличествоМест = Таб[0].гф_ТоварыВКоробах[0].КоличествоПар;
	ОбластьСтрока.Параметры.Упаковка       = Таб[0].гф_ТоварыВКоробах[0].УпаковочныйЛист.гф_Агрегация.ТипУпаковки;
	//ОбластьСтрока.Параметры.Наименование   = ;
	//ОбластьСтрока.Параметры.Статистика     = ;
	ОбластьСтрока.Параметры.Вес            = ТабНакладная[0].МассаБрутто;
	//ОбластьСтрока.Параметры.Объем          = ;
	ТабличныйДокумент.Вывести(ОбластьСтрока);
	//
	
	//Заполнение области подвал
	ОбластьПодвал.Параметры.Валюта      = Таб[0].Валюта.НаименованиеПолное;
	ОбластьПодвал.Параметры.СуммаЗаказа = Таб[0].СуммаВзаиморасчетов;
	ТабличныйДокумент.Вывести(ОбластьПодвал);
	//
	Возврат ТабличныйДокумент;
	
КонецФункции	

&ИзменениеИКонтроль("ДобавитьКомандыПечати")
Процедура гф_ДобавитьКомандыПечати(КомандыПечати, Порядок, УсловиеВидимости)

	Если ПолучитьФункциональнуюОпцию("ИспользоватьТТН")
		И ПравоДоступа("Просмотр", Метаданные.Документы.ТранспортнаяНакладная) Тогда

		ИнтерактивноеДобавление = ПравоДоступа("ИнтерактивноеДобавление", Метаданные.Документы.ТранспортнаяНакладная);

		// 1-Т (Товарно-транспортная накладная) 
		КомандаПечати = КомандыПечати.Добавить();
		КомандаПечати.МенеджерПечати = "";
		КомандаПечати.Обработчик = "ТранспортнаяНакладнаяКлиент.ПечатьТТН";
		КомандаПечати.Идентификатор = "ТТН";
		КомандаПечати.Представление = НСтр("ru = 'Товарно-транспортная накладная (1-Т)';
		|en = 'Waybill (1-T)'");
		КомандаПечати.ПроверкаПроведенияПередПечатью = Истина;
		КомандаПечати.ДополнительныеПараметры = Новый Структура("ИнтерактивноеДобавление", ИнтерактивноеДобавление);

		Если Порядок <> Неопределено Тогда
			КомандаПечати.Порядок = Порядок;
		КонецЕсли;

		Если УсловиеВидимости <> Неопределено Тогда
			КомандаПечати.УсловияВидимости.Добавить(УсловиеВидимости)
		КонецЕсли;

		// Транспортная накладная
		КомандаПечати = КомандыПечати.Добавить();
		КомандаПечати.МенеджерПечати = "";
		КомандаПечати.Обработчик = "ТранспортнаяНакладнаяКлиент.ПечатьТТН";
		КомандаПечати.Идентификатор = "ТранспортнаяНакладная";
		КомандаПечати.Представление = НСтр("ru = 'Транспортная накладная';
		|en = 'Consignment note'");
		КомандаПечати.ПроверкаПроведенияПередПечатью = Истина;
		КомандаПечати.ДополнительныеПараметры = Новый Структура("ИнтерактивноеДобавление", ИнтерактивноеДобавление);

		Если Порядок <> Неопределено Тогда
			КомандаПечати.Порядок = Порядок + 1;
		КонецЕсли;

		Если УсловиеВидимости <> Неопределено Тогда
			КомандаПечати.УсловияВидимости.Добавить(УсловиеВидимости)
		КонецЕсли;
		#Вставка
		// ++ ЕсиповАВ 26.01.24
		// Накладная CMR
		КомандаПечати = КомандыПечати.Добавить();
		КомандаПечати.МенеджерПечати = "";
		// СадомцевСА 30.01.2024
		// Исправил ошибку: "При формировании печатной формы "СМР" возникла ошибка. Обратитесь к администратору."
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eebf33cf19b0da
		КомандаПечати.Обработчик = "ТранспортнаяНакладнаяКлиент.ПечатьТТН"; //  добавил строку
		КомандаПечати.Идентификатор = "СМР";
		КомандаПечати.Представление = НСтр("ru = 'Накладная CMR';
		|en = 'CMR'");
		КомандаПечати.ПроверкаПроведенияПередПечатью = Истина;
		КомандаПечати.ДополнительныеПараметры = Новый Структура("ИнтерактивноеДобавление", ИнтерактивноеДобавление);

		Если Порядок <> Неопределено Тогда
			КомандаПечати.Порядок = Порядок + 1;
		КонецЕсли;

		Если УсловиеВидимости <> Неопределено Тогда
			КомандаПечати.УсловияВидимости.Добавить(УсловиеВидимости)
		КонецЕсли;
		// -- ЕсиповАВ 26.01.24
		#КонецВставки

	КонецЕсли;

КонецПроцедуры

#КонецЕсли