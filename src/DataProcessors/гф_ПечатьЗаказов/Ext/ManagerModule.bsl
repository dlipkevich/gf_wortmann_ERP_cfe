﻿Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	СтруктураТипов = ОбщегоНазначенияУТ.СоответствиеМассивовПоТипамОбъектов(МассивОбъектов);
	
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ЗаказПоставщикуСКартинками") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		"ЗаказПоставщикуСКартинками",
		НСтр("ru = 'Заказ поставщику с картинками';
		|en = 'Purchase Order with pictures'"),
		СформироватьПечатнуюФормуЗаказПоставщикуСКартинками(СтруктураТипов, ОбъектыПечати, ПараметрыПечати));
		
	КонецЕсли;
	
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ЗаказПоставщикуСКартинкамиРазмеры") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		"ЗаказПоставщикуСКартинкамиРазмеры",
		НСтр("ru = 'Заказ поставщику с картинками размеры';
		|en = 'Purchase Order with pictures size'"),
		СформироватьПечатнуюФормуЗаказПоставщикуСКартинкамиРазмеры(СтруктураТипов, ОбъектыПечати, ПараметрыПечати));
		
	КонецЕсли;
	
	ФормированиеПечатныхФорм.ЗаполнитьПараметрыОтправки(ПараметрыВывода.ПараметрыОтправки, СтруктураТипов, КоллекцияПечатныхФорм);
	
КонецПроцедуры

Функция СформироватьПечатнуюФормуЗаказПоставщикуСКартинками(СтруктураТипов, ОбъектыПечати, ПараметрыПечати) Экспорт
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.АвтоМасштаб = Истина;
	ТабличныйДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
	
	МассивДок = Новый Массив;
	
	Для Каждого СтруктураОбъектов Из СтруктураТипов Цикл
		
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(МассивДок, СтруктураОбъектов.Значение);
	
    КонецЦикла;
	
	МакетОбработки = ПолучитьМакет("ПФ_MXL_ЗаказПоставщикуСКартинками");
	ОбластьШапка = МакетОбработки.ПолучитьОбласть("Шапка");
	ОбластьСтрока = МакетОбработки.ПолучитьОбласть("Строка");
	ОбластьПодвал = МакетОбработки.ПолучитьОбласть("Подвал");
	
	//ОбластьОписаниеКартинка = МакетОбработки.ПолучитьОбласть("ОписаниеКартинка");
	//ОбластьСтрока.Присоединить(ОбластьОписаниеКартинка);
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ЗаказПоставщику.Ссылка КАК Ссылка,
	|	ЗаказПоставщику.Номер КАК Номер,
	|	ЗаказПоставщику.Дата КАК Дата,
	|	ЗаказПоставщику.Организация КАК Организация,
	|	ЗаказПоставщику.Контрагент КАК Контрагент,
	|	ЗаказПоставщику.Товары.(
	|		Ссылка КАК Ссылка,
	|		НомерСтроки КАК НомерСтроки,
	|		НоменклатураПартнера КАК НоменклатураПартнера,
	|		Номенклатура КАК Номенклатура,
	|		Характеристика КАК Характеристика,
	|		Упаковка КАК Упаковка,
	|		КоличествоУпаковок КАК КоличествоУпаковок,
	|		Количество КАК Количество,
	|		ДатаПоступления КАК ДатаПоступления,
	|		ВидЦеныПоставщика КАК ВидЦеныПоставщика,
	|		Цена КАК Цена,
	|		Сумма КАК Сумма,
	|		ПроцентРучнойСкидки КАК ПроцентРучнойСкидки,
	|		СуммаРучнойСкидки КАК СуммаРучнойСкидки,
	|		УдалитьСтавкаНДС КАК УдалитьСтавкаНДС,
	|		СтавкаНДС КАК СтавкаНДС,
	|		СуммаНДС КАК СуммаНДС,
	|		СуммаСНДС КАК СуммаСНДС,
	|		КодСтроки КАК КодСтроки,
	|		Отменено КАК Отменено,
	|		СтатьяРасходов КАК СтатьяРасходов,
	|		АналитикаРасходов КАК АналитикаРасходов,
	|		ПричинаОтмены КАК ПричинаОтмены,
	|		Склад КАК Склад,
	|		Назначение КАК Назначение,
	|		Подразделение КАК Подразделение,
	|		СписатьНаРасходы КАК СписатьНаРасходы,
	|		ИдентификаторСтроки КАК ИдентификаторСтроки,
	|		ДатаОтгрузки КАК ДатаОтгрузки
	|	) КАК Товары,
	|	ЗаказПоставщику.гф_ПродукцияВКоробах.(
	|		Ссылка КАК Ссылка,
	|		НомерСтроки КАК НомерСтроки,
	|		ВариантКомплектации КАК ВариантКомплектации,
	|		КоличествоКоробов КАК КоличествоКоробов,
	|		IDКороба КАК IDКороба,
	|		СтоимостьКороба КАК СтоимостьКороба,
	|		НДС КАК НДС,
	|		Сумма КАК Сумма
	|	) КАК гф_ПродукцияВКоробах,
	|	ЗаказПоставщику.СуммаДокумента КАК СуммаДокумента
	|ИЗ
	|	Документ.ЗаказПоставщику КАК ЗаказПоставщику
	|ГДЕ
	|	ЗаказПоставщику.Ссылка = &Ссылка";
	Запрос.Параметры.Вставить("Ссылка",МассивДок[0].Ссылка);
	Таб = Запрос.Выполнить().Выгрузить();
	
	// Заполнение области Шапка
	// Удаление нулей из номера документа
	НомерДок = Прав(Таб[0].Номер, 6);
	НомерБезНулей = НомерДок;
	Пока Найти(НомерБезНулей,"0") = 1 Цикл
		НомерБезНулей = Сред(НомерБезНулей,2); //удаляет лидирующие нули
	КонецЦикла;
	//
	ОбластьШапка.Параметры.НомерЗаказа = "Заказ поставщику № " + НомерБезНулей + " от " + Формат(Таб[0].Дата, "ДЛФ=ДД");
	ОбластьШапка.Параметры.Поставщик   = Таб[0].Организация.Наименование + ", ИНН " + Таб[0].Организация.ИНН + ", КПП " + Таб[0].Организация.КПП; 
	ОбластьШапка.Параметры.Покупатель  = Таб[0].Контрагент.Наименование + ", ИНН " + Таб[0].Контрагент.ИНН + ", КПП " + Таб[0].Контрагент.КПП;
	ТабличныйДокумент.Вывести(ОбластьШапка);
	//
	ТабличныйДокументКолонки = Новый ТабличныйДокумент;
	ТабличныйДокументЛево    = Новый ТабличныйДокумент;
	ТабличныйДокументЦентр   = Новый ТабличныйДокумент;
	ТабличныйДокументПраво   = Новый ТабличныйДокумент;
	ИтогоКоробов = 0;
	ИтогоПар     = 0;
	//Заполнение области Строка
	НомерСтроки = 1;
	Для Каждого СтрТов Из Таб[0].гф_ПродукцияВКоробах Цикл
		
		ОбластьЛево = МакетОбработки.ПолучитьОбласть("СтрокаЛево");
		ТабличныйДокументЛево.Вывести(ОбластьЛево);
		
		ОбластьОписаниеКартинка = МакетОбработки.ПолучитьОбласть("ОписаниеКартинка");
		ТабличныйДокументЦентр.Вывести(ОбластьОписаниеКартинка);
		
		ОбластьПраво = МакетОбработки.ПолучитьОбласть("СтрокаПраво");
		ТабличныйДокументПраво.Вывести(ОбластьПраво);
		
		Пар = 0;
		Для Каждого Стр Из Таб[0].Товары Цикл
			
			ОбластьЛево.Параметры.Номер                  = НомерСтроки;
			ОбластьПраво.Параметры.Пар                   = Стр.Упаковка.Наименование;
			ОбластьПраво.Параметры.Цена                  = Стр.СуммаСНДС;
			
			Запрос = Новый Запрос;
			Запрос.Текст =
			"ВЫБРАТЬ
			|	Номенклатура.Ссылка КАК Ссылка,
			|	Номенклатура.ФайлКартинки КАК ФайлКартинки
			|ИЗ
			|	Справочник.Номенклатура КАК Номенклатура
			|ГДЕ
			|	Номенклатура.Ссылка = &Ссылка";
			Запрос.Параметры.Вставить("Ссылка",Стр.Номенклатура.Ссылка);
			ТабНоменклатура = Запрос.Выполнить().Выгрузить();
			
			ИтогоПар = ИтогоПар + Стр.Количество;
			Пар =  Пар + Стр.Количество;
			
		КонецЦикла;
		
		Попытка
			УстановитьПривилегированныйРежим(Истина);
			КартинкаНоменклатуры = РаботаСФайлами.ДвоичныеДанныеФайла(ТабНоменклатура[0].ФайлКартинки);
			УстановитьПривилегированныйРежим(Ложь);
		Исключение
			КартинкаНоменклатуры = Неопределено;
		КонецПопытки;
		
		Если ЗначениеЗаполнено(КартинкаНоменклатуры) Тогда
			ОбластьКартинка = ОбластьОписаниеКартинка.Области.АдресКартинки;
			
			Если ТипЗнч(КартинкаНоменклатуры) = Тип("Картинка") Тогда
				ОбластьКартинка.Картинка = КартинкаНоменклатуры;
			ИначеЕсли ТипЗнч(КартинкаНоменклатуры) = Тип("ДвоичныеДанные") Тогда
				КартинкаКарточки = Новый Картинка(КартинкаНоменклатуры);
				
				ОбластьКартинка.Картинка = ?(КартинкаКарточки.Формат() = ФорматКартинки.НеизвестныйФормат,
				Неопределено,
				КартинкаКарточки);
			КонецЕсли;
			
		КонецЕсли;
		
		ОбластьПраво.Параметры.КоличествоПар         = Пар;
		ОбластьПраво.Параметры.Артикул               = СтрТов.ВариантКомплектации.Наименование;
		ОбластьПраво.Параметры.Товар                 = СтрТов.ВариантКомплектации.Владелец.НаименованиеПолное;
		//ОбластьПраво.Параметры.Цвет                  = ;
		ОбластьПраво.Параметры.ТорговаяМарка         = СтрТов.ВариантКомплектации.Владелец.Ссылка.Марка.Наименование;
		//ОбластьПраво.Параметры.НаименованиеПодкладки = ;
		//ОбластьПраво.Параметры.СрокПоставки          = ;
		ОбластьПраво.Параметры.КоличествоКоробов     = СтрТов.КоличествоКоробов;
		СчетДляИтого                                 = СтрТов.КоличествоКоробов;
		ОбластьПраво.Параметры.Единица               = СтрТов.ВариантКомплектации.Упаковка.Наименование;
		ОбластьПраво.Параметры.Сумма                 = СтрТов.КоличествоКоробов + СтрТов.СтоимостьКороба;
		
		НомерСтроки = НомерСтроки + 1;
		
		ТабличныйДокумент.Вывести(ОбластьЛево);
		ТабличныйДокумент.Присоединить(ОбластьОписаниеКартинка);
		ТабличныйДокумент.Присоединить(ОбластьПраво);
		
		ИтогоКоробов = ИтогоКоробов + СчетДляИтого;
		
	КонецЦикла;
	//
	ОбластьПодвал.Параметры.ИтогоКоличествоКоробов = ИтогоКоробов;
	ОбластьПодвал.Параметры.ИтогоКоличествоПар     = ИтогоПар;
	ОбластьПодвал.Параметры.ИтогоСумма             = Таб[0].СуммаДокумента;
	ОбластьПодвал.Параметры.НаименованийНаСумму = "Всего наименований " + НомерСтроки + " , на сумму " + Таб[0].СуммаДокумента + " руб.";
	ОбластьПодвал.Параметры.СуммаПрописью = ЧислоПрописью(Таб[0].СуммаДокумента, "Л=ru_RU", "рубль, рубля, рублей, м, копейка, копейки, копеек, ж, 2");
	//ОбластьПодвал.Параметры.Руководитель = ;
	//ОбластьПодвал.Параметры.Бухгалтер = ;
	
	ТабличныйДокумент.Вывести(ОбластьПодвал);
	
	Возврат ТабличныйДокумент;
	
КонецФункции	

Функция СформироватьПечатнуюФормуЗаказПоставщикуСКартинкамиРазмеры(СтруктураТипов, ОбъектыПечати, ПараметрыПечати) Экспорт
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.АвтоМасштаб = Истина;
	ТабличныйДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
	
	МассивДок = Новый Массив;
	
	Для Каждого СтруктураОбъектов Из СтруктураТипов Цикл
		
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(МассивДок, СтруктураОбъектов.Значение);
	
    КонецЦикла;
	
	МакетОбработки = ПолучитьМакет("ПФ_MXL_ЗаказПоставщикуСКартинкамиРазмеры");
	ОбластьШапка = МакетОбработки.ПолучитьОбласть("Шапка");
	ОбластьСтрока = МакетОбработки.ПолучитьОбласть("Строка");
	ОбластьПодвал = МакетОбработки.ПолучитьОбласть("Подвал");
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ЗаказПоставщику.Ссылка КАК Ссылка,
	|	ЗаказПоставщику.Номер КАК Номер,
	|	ЗаказПоставщику.Дата КАК Дата,
	|	ЗаказПоставщику.Организация КАК Организация,
	|	ЗаказПоставщику.Контрагент КАК Контрагент,
	|	ЗаказПоставщику.Товары.(
	|		Ссылка КАК Ссылка,
	|		НомерСтроки КАК НомерСтроки,
	|		НоменклатураПартнера КАК НоменклатураПартнера,
	|		Номенклатура КАК Номенклатура,
	|		Характеристика КАК Характеристика,
	|		Упаковка КАК Упаковка,
	|		КоличествоУпаковок КАК КоличествоУпаковок,
	|		Количество КАК Количество,
	|		ДатаПоступления КАК ДатаПоступления,
	|		ВидЦеныПоставщика КАК ВидЦеныПоставщика,
	|		Цена КАК Цена,
	|		Сумма КАК Сумма,
	|		ПроцентРучнойСкидки КАК ПроцентРучнойСкидки,
	|		СуммаРучнойСкидки КАК СуммаРучнойСкидки,
	|		УдалитьСтавкаНДС КАК УдалитьСтавкаНДС,
	|		СтавкаНДС КАК СтавкаНДС,
	|		СуммаНДС КАК СуммаНДС,
	|		СуммаСНДС КАК СуммаСНДС,
	|		КодСтроки КАК КодСтроки,
	|		Отменено КАК Отменено,
	|		СтатьяРасходов КАК СтатьяРасходов,
	|		АналитикаРасходов КАК АналитикаРасходов,
	|		ПричинаОтмены КАК ПричинаОтмены,
	|		Склад КАК Склад,
	|		Назначение КАК Назначение,
	|		Подразделение КАК Подразделение,
	|		СписатьНаРасходы КАК СписатьНаРасходы,
	|		ИдентификаторСтроки КАК ИдентификаторСтроки,
	|		ДатаОтгрузки КАК ДатаОтгрузки
	|	) КАК Товары,
	|	ЗаказПоставщику.гф_ПродукцияВКоробах.(
	|		Ссылка КАК Ссылка,
	|		НомерСтроки КАК НомерСтроки,
	|		ВариантКомплектации КАК ВариантКомплектации,
	|		КоличествоКоробов КАК КоличествоКоробов,
	|		IDКороба КАК IDКороба,
	|		СтоимостьКороба КАК СтоимостьКороба,
	|		НДС КАК НДС,
	|		Сумма КАК Сумма
	|	) КАК гф_ПродукцияВКоробах,
	|	ЗаказПоставщику.СуммаДокумента КАК СуммаДокумента
	|ИЗ
	|	Документ.ЗаказПоставщику КАК ЗаказПоставщику
	|ГДЕ
	|	ЗаказПоставщику.Ссылка = &Ссылка";
	Запрос.Параметры.Вставить("Ссылка",МассивДок[0].Ссылка);
	Таб = Запрос.Выполнить().Выгрузить();
	
	// Заполнение области Шапка
	// Удаление нулей из номера документа
	НомерДок = Прав(Таб[0].Номер, 6);
	НомерБезНулей = НомерДок;
	Пока Найти(НомерБезНулей,"0") = 1 Цикл
		НомерБезНулей = Сред(НомерБезНулей,2); //удаляет лидирующие нули
	КонецЦикла;
	//
	ОбластьШапка.Параметры.НомерЗаказа = "Заказ поставщику № " + НомерБезНулей + " от " + Формат(Таб[0].Дата, "ДЛФ=ДД");
	ОбластьШапка.Параметры.Поставщик   = Таб[0].Организация.Наименование + ", ИНН " + Таб[0].Организация.ИНН + ", КПП " + Таб[0].Организация.КПП; 
	ОбластьШапка.Параметры.Покупатель  = Таб[0].Контрагент.Наименование + ", ИНН " + Таб[0].Контрагент.ИНН + ", КПП " + Таб[0].Контрагент.КПП;
	ТабличныйДокумент.Вывести(ОбластьШапка);
	//
	ТабличныйДокументКолонки = Новый ТабличныйДокумент;
	ТабличныйДокументЛево    = Новый ТабличныйДокумент;
	ТабличныйДокументЦентр   = Новый ТабличныйДокумент;
	ТабличныйДокументПраво   = Новый ТабличныйДокумент;
	ИтогоКоробов = 0;
	ИтогоПар     = 0;
	//Заполнение области Строка
	НомерСтроки = 1;
	Для Каждого СтрТов Из Таб[0].гф_ПродукцияВКоробах Цикл
		
		ОбластьЛево = МакетОбработки.ПолучитьОбласть("СтрокаЛево");
		ТабличныйДокументЛево.Вывести(ОбластьЛево);
		
		ОбластьОписаниеКартинка = МакетОбработки.ПолучитьОбласть("ОписаниеКартинка");
		ТабличныйДокументЦентр.Вывести(ОбластьОписаниеКартинка);
		
		ОбластьПраво = МакетОбработки.ПолучитьОбласть("СтрокаПраво");
		ТабличныйДокументПраво.Вывести(ОбластьПраво);
		
		Пары = "";
		Размер = "";
		
		Для Каждого Стр Из Таб[0].Товары Цикл
			
			Пары = Пары + Стр.Количество + "
			|";
			Размер = Размер + Стр.Характеристика.Наименование + "
			|";
			ОбластьЛево.Параметры.Номер                  = НомерСтроки;
			ОбластьПраво.Параметры.Пар                   = Стр.Упаковка.Наименование;
			ОбластьПраво.Параметры.Цена                  = Стр.СуммаСНДС;
			
			Запрос = Новый Запрос;
			Запрос.Текст =
			"ВЫБРАТЬ
			|	Номенклатура.Ссылка КАК Ссылка,
			|	Номенклатура.ФайлКартинки КАК ФайлКартинки
			|ИЗ
			|	Справочник.Номенклатура КАК Номенклатура
			|ГДЕ
			|	Номенклатура.Ссылка = &Ссылка";
			Запрос.Параметры.Вставить("Ссылка",Стр.Номенклатура.Ссылка);
			ТабНоменклатура = Запрос.Выполнить().Выгрузить();
			
			ИтогоПар = ИтогоПар + Стр.Количество;
			
		КонецЦикла;
		
		Попытка
			УстановитьПривилегированныйРежим(Истина);
			КартинкаНоменклатуры = РаботаСФайлами.ДвоичныеДанныеФайла(ТабНоменклатура[0].ФайлКартинки);
			УстановитьПривилегированныйРежим(Ложь);
		Исключение
			КартинкаНоменклатуры = Неопределено;
		КонецПопытки;
		
		Если ЗначениеЗаполнено(КартинкаНоменклатуры) Тогда
			ОбластьКартинка = ОбластьОписаниеКартинка.Области.АдресКартинки;
			
			Если ТипЗнч(КартинкаНоменклатуры) = Тип("Картинка") Тогда
				ОбластьКартинка.Картинка = КартинкаНоменклатуры;
			ИначеЕсли ТипЗнч(КартинкаНоменклатуры) = Тип("ДвоичныеДанные") Тогда
				КартинкаКарточки = Новый Картинка(КартинкаНоменклатуры);
				
				ОбластьКартинка.Картинка = ?(КартинкаКарточки.Формат() = ФорматКартинки.НеизвестныйФормат,
				Неопределено,
				КартинкаКарточки);
			КонецЕсли;
			
		КонецЕсли;
		
		ОбластьПраво.Параметры.Артикул               = СтрТов.ВариантКомплектации.Наименование;
		ОбластьПраво.Параметры.Товар                 = СтрТов.ВариантКомплектации.Владелец.НаименованиеПолное;
		//ОбластьПраво.Параметры.Цвет                  = ;
		ОбластьПраво.Параметры.ТорговаяМарка         = СтрТов.ВариантКомплектации.Владелец.Ссылка.Марка.Наименование;
		ОбластьПраво.Параметры.Размеры               = Размер;
		ОбластьПраво.Параметры.КоличествоПар         = Пары;
		ОбластьПраво.Параметры.Сумма                 = СтрТов.КоличествоКоробов + СтрТов.СтоимостьКороба;
		
		
		НомерСтроки = НомерСтроки + 1;	
		
		ТабличныйДокумент.Вывести(ОбластьЛево);
		ТабличныйДокумент.Присоединить(ОбластьОписаниеКартинка);
		ТабличныйДокумент.Присоединить(ОбластьПраво);
		
	КонецЦикла;
	//
    
	ОбластьПодвал.Параметры.ИтогоКоличествоПар     = ИтогоПар;
	ОбластьПодвал.Параметры.ИтогоСумма             = Таб[0].СуммаДокумента;
	ОбластьПодвал.Параметры.НаименованийНаСумму = "Всего наименований " + НомерСтроки + " , на сумму " + Таб[0].СуммаДокумента + " руб.";
	ОбластьПодвал.Параметры.СуммаПрописью = ЧислоПрописью(Таб[0].СуммаДокумента, "Л=ru_RU", "рубль, рубля, рублей, м, копейка, копейки, копеек, ж, 2");
	//ОбластьПодвал.Параметры.Руководитель = ;
	//ОбластьПодвал.Параметры.Бухгалтер = ;
	
	ТабличныйДокумент.Вывести(ОбластьПодвал);
	
	Возврат ТабличныйДокумент;
	
КонецФункции	