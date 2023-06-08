﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область Печать

&После ("ДобавитьКомандыПечати")
Процедура гф_ДобавитьКомандыПечати(КомандыПечати)
	
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "гф_МастерДанныеПеремещениеHellmann";
	КомандаПечати.Представление = НСтр("ru = 'Мастер данные перемещение Hellmann';
	|en = 'Item code list Hellmann'");
	КомандаПечати.ПроверкаПроведенияПередПечатью = Истина;
	КомандаПечати.Порядок = 10;
	
КонецПроцедуры

&После ("Печать")
Процедура гф_Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	// ++ Галфинд ЕсиповАВ 30.12.2022
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "гф_МастерДанныеПеремещениеHellmann") Тогда
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		"гф_МастерДанныеПеремещениеHellmann",
		НСтр("ru = 'Мастер данные перемещение Hellmann';
		|en = 'Item code list'"),
			гф_СформироватьПечатнуюФормуМастерДанныеПеремещениеHellmann(МассивОбъектов, ОбъектыПечати),
			,
			"Документ.ПеремещениеТоваров.гф_МастерДанныеПеремещениеHellmann");
	КонецЕсли;

КонецПроцедуры

&ИзменениеИКонтроль("СформироватьКомплектПечатныхФорм")
Функция гф_СформироватьКомплектПечатныхФорм(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати)

	Перем АдресКомплектаПечатныхФорм;

	Если ТипЗнч(ПараметрыПечати) = Тип("Структура") И ПараметрыПечати.Свойство("АдресКомплектаПечатныхФорм", АдресКомплектаПечатныхФорм) Тогда

		КомплектПечатныхФорм = ПолучитьИзВременногоХранилища(АдресКомплектаПечатныхФорм);

	Иначе
		КомплектПечатныхФорм = РегистрыСведений.НастройкиПечатиОбъектов.КомплектПечатныхФорм(
		Метаданные.Документы.ПеремещениеТоваров.ПолноеИмя(),
		МассивОбъектов, Неопределено);

	КонецЕсли;

	Если КомплектПечатныхФорм = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"НакладнаяНаПеремещение");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		СформироватьПечатнуюФормуНакладнойНаПеремещениеТоваров(КомплектПечати.Объекты, ОбъектыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"СертификатыНоменклатурыРеестр");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Справочники.СертификатыНоменклатуры.СформироватьПечатнуюФормуРеестрСертификатовНоменклатуры(КомплектПечати.Объекты, ОбъектыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"СертификатыНоменклатурыИзображенияИзДокументов");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Справочники.СертификатыНоменклатуры.СформироватьПечатнуюФормуИзображенияСертификатовИзДокументов(КомплектПечати.Объекты, ОбъектыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"СертификатыНоменклатурыИзображенияИзДокументовБезДублей");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Справочники.СертификатыНоменклатуры.СформироватьПечатнуюФормуИзображенияСертификатовИзДокументовБезДублей(КомплектПечати.Объекты, ОбъектыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"ЗаданиеНаОтборРазмещениеТовара");
	#Вставка
	// ++ Галфинд ВолковЕВ 08.06.2023
	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"гф_МастерДанныеПеремещениеHellmann");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		гф_СформироватьПечатнуюФормуМастерДанныеПеремещениеHellmann(КомплектПечати.Объекты, ОбъектыПечати));
	КонецЦикла;
	//-- Галфинд ВолковЕВ 08.06.2023
	#КонецВставки

	ПараметрыПечати.Вставить("ТипЗадания", "ЗаданиеНаОтбор");

	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл

		СтруктураТипов = Новый Соответствие;
		СтруктураТипов.Вставить("Документ.ПеремещениеТоваров", КомплектПечати.Объекты);

		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Обработки.ПечатьЗаданияНаОтборРазмещениеТоваров.СформироватьЗаданиеНаОтборРазмещениеТовара(СтруктураТипов,
		ОбъектыПечати,
		ПараметрыПечати));

	КонецЦикла;

	ПеремещениеТоваровЛокализация.СформироватьКомплектПечатныхФорм(МассивОбъектов, 
	ПараметрыПечати,
	КоллекцияПечатныхФорм,
	ОбъектыПечати,
	КомплектПечатныхФорм);

	РегистрыСведений.НастройкиПечатиОбъектов.СформироватьКомплектВнешнихПечатныхФорм(
	"Документ.ПеремещениеТоваров",
	МассивОбъектов,
	ПараметрыПечати,
	КоллекцияПечатныхФорм,
	ОбъектыПечати);

КонецФункции

Функция гф_СформироватьПечатнуюФормуМастерДанныеПеремещениеHellmann(МассивОбъектов, ОбъектыПечати) Экспорт
	
	Перем КодНайден;
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "ПараметрыПечати_ДефектнаяВедомостьЗаявкаНаРемонт";
	
	ПервыйДокумент = Истина;
	
	Для Каждого ТекущийДокумент Из МассивОбъектов Цикл
		
		Если Не ПервыйДокумент Тогда
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		ПервыйДокумент = Ложь;
		
		НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
		
		
	Если ТипЗнч(ТекущийДокумент) = Тип("ДокументСсылка.ВнутреннееПотребление") Тогда
		Если ТипЗнч(ТекущийДокумент.Заказчик) = Тип("СправочникСсылка.Склады") Тогда
			КодКлиента = гф_ПолучитьКодКлиента(ТекущийДокумент.Заказчик, КодНайден);
		Иначе
			КодКлиента = "";
			КодНайден = Ложь;
		КонецЕсли;
	Иначе
		КодКлиента = гф_ПолучитьКодКлиента(ТекущийДокумент.СкладПолучатель, КодНайден);
	КонецЕсли;
	
	запрос = новый Запрос(
	"ВЫБРАТЬ
	|	таб.Номенклатура КАК Номенклатура
	|ПОМЕСТИТЬ таб
	|ИЗ
	|	&таб КАК таб
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	таб.Номенклатура КАК Номенклатура,
	|	свойствоДлина.Значение КАК Длина,
	|	свойствШирина.Значение КАК Ширина,
	|	свойствоВысота.Значение КАК Высота,
	|	(ВЫРАЗИТЬ(свойствВес.Значение КАК ЧИСЛО(17, 3))) / 1000 КАК Вес,
	|	ВЫБОР
	|		КОГДА к.Категория ЕСТЬ NULL
	|			ТОГДА ЛОЖЬ
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ КАК ВестиУчетСерийныхНомеров
	|ИЗ
	|	таб КАК таб
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияСвойствОбъектов КАК свойствоДлина
	|		ПО таб.Номенклатура = свойствоДлина.Объект
	|			И (свойствоДлина.Свойство = &длина)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияСвойствОбъектов КАК свойствШирина
	|		ПО таб.Номенклатура = свойствШирина.Объект
	|			И (свойствШирина.Свойство = &шинира)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияСвойствОбъектов КАК свойствоВысота
	|		ПО таб.Номенклатура = свойствоВысота.Объект
	|			И (свойствоВысота.Свойство = &высота)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияСвойствОбъектов КАК свойствВес
	|		ПО таб.Номенклатура = свойствВес.Объект
	|			И (свойствВес.Свойство = &вес)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КатегорииОбъектов КАК к
	|		ПО таб.Номенклатура = к.Объект
	|			И (к.Категория = &Категория)
	|
	|УПОРЯДОЧИТЬ ПО
	|	Номенклатура
	|АВТОУПОРЯДОЧИВАНИЕ");
	запрос.УстановитьПараметр("таб", ТекущийДокумент.Товары.Выгрузить(,"Номенклатура"));
	запрос.УстановитьПараметр("длина", Справочники.B2B_w_Настройки.Свойство_Carton_Length.Значение);
	запрос.УстановитьПараметр("шинира", Справочники.B2B_w_Настройки.Свойство_Carton_Width.Значение);
	запрос.УстановитьПараметр("высота", Справочники.B2B_w_Настройки.Свойство_Carton_Height.Значение);
	запрос.УстановитьПараметр("вес", Справочники.B2B_w_Настройки.Свойство_Carton_Weight.Значение);
	запрос.УстановитьПараметр("Категория", Справочники.B2B_w_Настройки.Категория_ВестиУчетСерийныхНомеров.Значение);
	
	// Волков данные не понятно из какого регистра брать
	//выборка2 = запрос.Выполнить().Выбрать();
	// Волков
	
	//ТабличныйДокумент = Новый ТабличныйДокумент;
	//Цены
	ЗапросЦены = Новый Запрос;
	ЗапросЦены.Текст = 
	"ВЫБРАТЬ
	|	ЦеныНоменклатурыСрезПоследних.Номенклатура КАК Номенклатура,
	|	ЦеныНоменклатурыСрезПоследних.Цена КАК Цена,
	|	ЦеныНоменклатурыСрезПоследних.ВидЦены КАК ВидЦены,
	|	ЦеныНоменклатурыСрезПоследних.Номенклатура.ЕдиницаИзмерения КАК НоменклатураЕдиницаИзмерения
	|ИЗ
	|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(&ДатаДокумента, ВидЦены = &ВидЦены) КАК ЦеныНоменклатурыСрезПоследних
	|ГДЕ
	|	ЦеныНоменклатурыСрезПоследних.ВидЦены = &ВидЦены";
	ЗапросЦены.УстановитьПараметр("ВидЦены", Справочники.ВидыЦен.НайтиПоНаименованию("Effective_purch_price_RU"));
	ЗапросЦены.УстановитьПараметр("ДатаДокумента", ТекущийДокумент.Дата);
	ТабЦен = ЗапросЦены.Выполнить().Выгрузить();
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
		
	//Если найти(ТекущийДокумент.СкладОтправитель.Наименование, "Основной") > 0
	//	или найти(ТекущийДокумент.СкладОтправитель.Наименование, "Свободн") > 0
	//	или найти(ТекущийДокумент.СкладОтправитель.Наименование, "Транзит") > 0 Тогда
	//	Макет = ПолучитьМакет("МастерДанные");
	//Иначе
	//	Макет = ПолучитьМакет("МастерДанныеНовый");
	//КонецЕсли;
	
	Если КодНайден Тогда
		//Макет = ПолучитьМакет("МастерДанныеНовый");
		Макет = ПолучитьМакет("гф_МастерДанныеНовый_10092019");
	Иначе
		Макет = ПолучитьМакет("гф_МастерДанные_10092019");
	КонецЕсли;
	
	ОбластьЗаголовок = Макет.ПолучитьОбласть("Шапка");
	ОбластьСтрока = Макет.ПолучитьОбласть("Строка");
	
	ТабличныйДокумент.Вывести(ОбластьЗаголовок);
	Если КодНайден Тогда
		ТабличныйДокумент.Вывести(Макет.ПолучитьОбласть("Пустая"));
	КонецЕсли;
	
	Для каждого Стр из ТекущийДокумент.Товары цикл
		//ОбработкаПрерыванияПользователя();
		
		ОбластьСтрока.Параметры.КодСклада 		= "01";
		ОбластьСтрока.Параметры.КодКлиента 		= КодКлиента;
		ОбластьСтрока.Параметры.Артикул 		= Стр.Номенклатура.Артикул;
		ОбластьСтрока.Параметры.Описание 		= Стр.Номенклатура.Наименование;
		ОбластьСтрока.Параметры.КороткоеОписание = Стр.Номенклатура.Наименование;
		ОбластьСтрока.Параметры.ЕдИзм = "упак";
		
		Цена = "";
		МассивЦен = ТабЦен.НайтиСтроки(Новый Структура("Номенклатура",Стр.Номенклатура));
		Для каждого Эл из МассивЦен цикл
			Цена = Эл.Цена;
		КонецЦикла;
		
		ОбластьСтрока.Параметры.Цена = СтрЗаменить(Цена, " ", "");
		
		
		// Волков данные не понятно из какого регистра брать
		//выборка2.НайтиСледующий(новый Структура("Номенклатура", Стр.Номенклатура));
		//ОбластьСтрока.Параметры.Заполнить(выборка2);
		// Волков
		
		
		
		
		
		//Если выборка2.ВестиУчетСерийныхНомеров Тогда //СтрокаТЧДокумента.Номенклатура.Категория.Вести учет серийных номеров
		//	Если Стр.СерияНоменклатуры.Пустая() Тогда
		//		НовыйШтрихКод = "";
		//	Иначе
		//		НовыйШтрихКод = Стр.СерияНоменклатуры.СерийныйНомер;
		//	КонецЕсли;
		//Иначе
		НовыйШтрихКод = СтрЗаменить(СокрЛП(Стр.Номенклатура.Артикул), "-", "");
		НовыйШтрихКод = СтрЗаменить(НовыйШтрихКод, ".", "");
		НовыйШтрихКод = СтрЗаменить(НовыйШтрихКод, "/", "");
		
		//расчет контрольного числа
		ДлинаШтрихкода = СтрДлина(НовыйШтрихКод);  
		
		//правка лысов
		// загрушка, слетает на артикулах кроме ботинкоф
		Если ДлинаШтрихкода = 15 Тогда
			Четные = 0;
			Нечетные = 0;
			
			Для н = 0 по ДлинаШтрихкода - 1 цикл
				Поз = ДлинаШтрихкода - н;
				Символ = Сред(НовыйШтрихКод,Поз, 1);	  
				Если Цел(Поз/2) * 2 = Поз тогда
					Четные = Четные + Число(Символ);
				Иначе
					Нечетные = Нечетные + Число(Символ);
				КонецЕсли;
			КонецЦикла;
			
			СуммаЧисел = Нечетные * 3 + Четные;  
			КонтрольноеЧисло = 0;
			
			Если СуммаЧисел = 0 тогда
				КонтрольноеЧисло = 0;
			Иначе
				Если СтрДлина(СуммаЧисел) > 1 тогда
					БлижайшееЧисло = Цел(СуммаЧисел / 10) * 10 + 10;
				ИначеЕсли СтрДлина(СуммаЧисел) = 1 тогда
					БлижайшееЧисло = 10;
				КонецЕсли;
				
				КонтрольноеЧисло = БлижайшееЧисло - СуммаЧисел;  			
				Если КонтрольноеЧисло = 10 тогда
					КонтрольноеЧисло = 0;	
				КонецЕсли;
				
				//Сообщить("БлижайшееЧисло " + БлижайшееЧисло + " КонтрольноеЧисло " + КонтрольноеЧисло);
				
			КонецЕсли;
			
			НовыйШтрихКод = НовыйШтрихКод + КонтрольноеЧисло;
		Иначе
			НовыйШтрихКод = Стр.Номенклатура.Код;
		КонецЕсли;
		//КонецЕсли;
		
		//!правка
		
		ОбластьСтрока.Параметры.ШтрихКод = НовыйШтрихКод; 
		//ОбластьСтрока.Параметры.ШтрихКод = СокрЛП(Стр.Номенклатура.Код); 
		
		ТабличныйДокумент.Вывести(ОбластьСтрока);
		
	КонецЦикла;
	
	ТабличныйДокумент.ОтображатьГруппировки = Ложь;
	ТабличныйДокумент.ОтображатьЗаголовки = Ложь;
	ТабличныйДокумент.ОтображатьСетку = Ложь;
	
	ПрефиксМонокоробов = "";
	
	Если ТипЗнч(ТекущийДокумент) = Тип("ДокументСсылка.ПеремещениеТоваров") и ТекущийДокумент.СкладПолучатель = Справочники.B2B_w_Настройки.СкладМонокороба.Значение
		или  ТипЗнч(ТекущийДокумент) = Тип("ДокументСсылка.ВнутреннееПотребление") и ТипЗнч(ТекущийДокумент.Заказчик) = Тип("СправочникСсылка.Склады")
		и ТекущийДокумент.Заказчик = Справочники.B2B_w_Настройки.СкладМонокороба.Значение Тогда
		ПрефиксМонокоробов = "-M";
	КонецЕсли;
	
	//ИмяФайла = "item_import_wortmann_" + КодКлиента + "_"  + СокрЛП(ТекущийДокумент.Номер) + ПрефиксМонокоробов + "_"  + День(ТекущийДокумент.Дата) + "_" + Месяц(ТекущийДокумент.Дата) + "_" + Прав(Год(ТекущийДокумент.Дата),2)+".xls";
	
	//Сообщить("Имя файла МастерДанные: " + ИмяФайла);
	
	//Возврат ТабличныйДокумент;
		
	КонецЦикла;
	
	ТабличныйДокумент.АвтоМасштаб = Истина;
	
	Возврат ТабличныйДокумент;
	
КонецФункции

#КонецОбласти

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

		ТекстЗапросаТаблицаЗаказыНаПеремещение(Запрос, ТекстыЗапроса, Регистры);
		ТекстЗапросаТаблицаДвиженияСерийТоваров(Запрос, ТекстыЗапроса, Регистры);
		ТекстЗапросаТаблицаТоварыОрганизаций(Запрос, ТекстыЗапроса, Регистры);
		ТекстЗапросаТаблицаСебестоимостьТоваров(Запрос, ТекстыЗапроса, Регистры);
		ТекстЗапросаТаблицаТоварыОрганизацийКПередаче(Запрос, ТекстыЗапроса, Регистры);
		ТекстЗапросаТаблицаРеестрДокументов(Запрос, ТекстыЗапроса, Регистры);
		ТекстЗапросаТаблицаТоварыКОформлениюОтчетовКомитенту(Запрос, ТекстыЗапроса, Регистры);
		ТекстЗапросаТаблицаДвиженияНоменклатураНоменклатура(Запрос, ТекстыЗапроса, Регистры);
		#Вставка
		Если ЗначениеЗаполнено(Документ.гф_ЗаказКлиента) Тогда
			гф_ТекстЗапросаТаблицаЗаказыКлиентов(Запрос, ТекстыЗапроса, Регистры)
		КонецЕсли;
		#КонецВставки

		РасчетСебестоимостиПроведениеДокументов.ОтразитьВМеханизмеУчетаЗатратИСебестоимости(Документ, Запрос, ТекстыЗапроса, Регистры);

		ПеремещениеТоваровЛокализация.ДополнитьТекстыЗапросовПроведения(Запрос, ТекстыЗапроса, Регистры);
	КонецЕсли;

	ОтразитьРаспределениеЗапасовДвижения(Запрос, ТекстыЗапроса, Регистры);
	ОформитьПриобретениеТоваровПоДвухходовке(Запрос, ТекстыЗапроса, Регистры);
	ОформитьПоступлениеТоваровПоДвухходовке(Запрос, ТекстыЗапроса, Регистры);
	ЗапланироватьПоступлениеТоваров(Запрос, ТекстыЗапроса, Регистры);
	ЗапланироватьОтгрузкуТоваров(Запрос, ТекстыЗапроса, Регистры);
	ОформитьОтгрузкуТоваров(Запрос, ТекстыЗапроса, Регистры);
	#Вставка
	Если ЗначениеЗаполнено(Документ.гф_ЗаказКлиента) Тогда
		//гф_ОтразитьРаспределениеОтгрузкиПеремещением(Запрос, ТекстыЗапроса, Регистры);
	КонецЕсли;
	#КонецВставки

	ПроведениеДокументов.ДобавитьЗапросыСторноДвижений(
	Запрос, ТекстыЗапроса, Регистры, Метаданные.Документы.ПеремещениеТоваров);

	////////////////////////////////////////////////////////////////////////////
	// Получим таблицы для движений

	Возврат ПроведениеДокументов.ИнициализироватьДанныеДокументаДляПроведения(Запрос, ТекстыЗапроса, ДопПараметры);

КонецФункции

Процедура гф_ОтразитьРаспределениеОтгрузкиПеремещением(Запрос, ТекстыЗапроса, Регистры)
	
	ТекстЗапросаТабЧасть =
		"ВЫБРАТЬ
		|	ТабЧасть.Ссылка                  КАК Ссылка,
		|	ТабЧасть.Ссылка.Дата             КАК Период,
		|	ТабЧасть.Номенклатура            КАК Номенклатура,
		|	ТабЧасть.Характеристика          КАК Характеристика,
		|	ТабЧасть.Ссылка.СкладОтправитель КАК Склад,
		|	ТабЧасть.НазначениеОтправителя   КАК Назначение,
		|	ТабЧасть.Количество              КАК Количество,
		|	НЕОПРЕДЕЛЕНО                     КАК ЗапланированныйРасходРаспределенногоЗапаса,
		|	ИСТИНА                           КАК КонтрольСвободногоОстатка,
		|	ЛОЖЬ                             КАК ИгнорироватьРезервыПриКонтролеОстатков
		|ИЗ
		|	Документ.ПеремещениеТоваров.Товары КАК ТабЧасть
		|ГДЕ
		|	ТабЧасть.КодСтроки = 0";
	
	РаспределениеЗапасовДвижения.РасходЗапаса(Запрос, ТекстыЗапроса, Регистры, ТекстЗапросаТабЧасть);
	
	ТекстЗапросаТабЧасть =
		// Приход на неордерном складе или по старым назначениям.
		"ВЫБРАТЬ
		|	ТабЧасть.Ссылка                                                КАК Ссылка,
		|	ТабЧасть.Ссылка.Дата                                           КАК Период,
		|	ТабЧасть.Номенклатура                                          КАК Номенклатура,
		|	ТабЧасть.Характеристика                                        КАК Характеристика,
		|	ТабЧасть.Ссылка.СкладПолучатель                                КАК Склад,
		|	ТабЧасть.Назначение                                            КАК Назначение,
		|	ТабЧасть.Количество                                            КАК Количество,
		|	ТабЧасть.Ссылка.ПеремещениеПоЗаказам И ТабЧасть.КодСтроки <> 0 КАК ПоГрафику,
		|	ТабЧасть.ЗаказНаПеремещение КАК РаспоряжениеВГрафике
		|ИЗ
		|	Документ.ПеремещениеТоваров.Товары КАК ТабЧасть
		|ГДЕ
		|	ТабЧасть.Ссылка.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыПеремещенийТоваров.Принято)
		|		И (НЕ ТабЧасть.Ссылка.СкладПолучатель.ИспользоватьОрдернуюСхемуПриПоступлении
		|			ИЛИ ТабЧасть.Ссылка.СкладПолучатель.ДатаНачалаОрдернойСхемыПриПоступлении > ТабЧасть.Ссылка.Дата
		|			ИЛИ ТабЧасть.Назначение.ДвиженияПоСкладскимРегистрам = ЛОЖЬ)";
	
	РаспределениеЗапасовДвижения.ПриходЗапаса(Запрос, ТекстыЗапроса, Регистры, ТекстЗапросаТабЧасть);
	
	ТекстЗапросаТабЧасть =
		// Сторно приходного ордера по старым назначениям.
		"ВЫБРАТЬ
		|	ТабЧасть.Ссылка                              КАК Ссылка,
		|	ТабЧасть.Ссылка.Дата                         КАК Период,
		|	ТабЧасть.Номенклатура                        КАК Номенклатура,
		|	ТабЧасть.Характеристика                      КАК Характеристика,
		|	ТабЧасть.Ссылка.СкладПолучатель              КАК Склад,
		|	ЗНАЧЕНИЕ(Справочник.Назначения.ПустаяСсылка) КАК Назначение,
		|	-ТабЧасть.Количество                         КАК Количество,
		|	ЛОЖЬ                                         КАК ПоГрафику,
		|	НЕОПРЕДЕЛЕНО                                 КАК РаспоряжениеВГрафике
		|ИЗ
		|	Документ.ПеремещениеТоваров.Товары КАК ТабЧасть
		|ГДЕ
		|	ТабЧасть.Ссылка.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыПеремещенийТоваров.Принято)
		|		И ТабЧасть.Назначение.ДвиженияПоСкладскимРегистрам = ЛОЖЬ
		|		И ТабЧасть.Ссылка.СкладПолучатель.ИспользоватьОрдернуюСхемуПриПоступлении
		|		И ТабЧасть.Ссылка.СкладПолучатель.ДатаНачалаОрдернойСхемыПриПоступлении <= ТабЧасть.Ссылка.Дата";
	
	РаспределениеЗапасовДвижения.ПриходЗапаса(Запрос, ТекстыЗапроса, Регистры, ТекстЗапросаТабЧасть);
	
	ТекстЗапросаТабЧасть =
		"ВЫБРАТЬ
		|	ТабЧасть.Ссылка                                                КАК Ссылка,
		|	ТабЧасть.Ссылка.Дата                                           КАК Период,
		|	ТабЧасть.Номенклатура                                          КАК Номенклатура,
		|	ТабЧасть.Характеристика                                        КАК Характеристика,
		|	ТабЧасть.Ссылка.СкладПолучатель                                КАК Склад,
		|	
		|	ВЫБОР КОГДА ТабЧасть.Назначение.ДвиженияПоСкладскимРегистрам = ЛОЖЬ ТОГДА
		|				ЗНАЧЕНИЕ(Справочник.Назначения.ПустаяСсылка)
		|			ИНАЧЕ
		|				ТабЧасть.Назначение
		|		КОНЕЦ КАК Назначение,
		|	
		|	ТабЧасть.Количество                                            КАК Количество,
		|	
		|	ВЫБОР КОГДА ТабЧасть.Ссылка.ПеремещениеПоЗаказам
		|					И ТабЧасть.Ссылка.ВариантПриемкиТоваров
		|						<> ЗНАЧЕНИЕ(Перечисление.ВариантыПриемкиТоваров.РазделенаТолькоПоНакладным) ТОГДА
		|				ТабЧасть.ЗаказНаПеремещение
		|			ИНАЧЕ
		|				ТабЧасть.Ссылка
		|		КОНЕЦ КАК Заказ,
		|	
		|	ВЫБОР КОГДА ТабЧасть.Ссылка.ДатаПоступления <> ДАТАВРЕМЯ(1, 1, 1) ТОГДА
		|				ТабЧасть.Ссылка.ДатаПоступления
		|			ИНАЧЕ
		|				ТабЧасть.Ссылка.Дата
		|		КОНЕЦ КАК ДатаПоступления,
		|	
		|	ИСТИНА                                                         КАК ДоступенДляРасхода,
		|	ТабЧасть.Ссылка.ПеремещениеПоЗаказам И ТабЧасть.КодСтроки <> 0 КАК ПоГрафику,
		|	ТабЧасть.ЗаказНаПеремещение                                    КАК РаспоряжениеВГрафике,
		|	ТабЧасть.Количество                                            КАК КоличествоВГрафике
		|ИЗ
		|	Документ.ПеремещениеТоваров.Товары КАК ТабЧасть
		|ГДЕ
		|	ТабЧасть.Ссылка.СкладПолучатель.ИспользоватьОрдернуюСхемуПриПоступлении
		|			И ТабЧасть.Ссылка.СкладПолучатель.ДатаНачалаОрдернойСхемыПриПоступлении <= ТабЧасть.Ссылка.Дата
		|			И (ТабЧасть.Ссылка.ВариантПриемкиТоваров = ЗНАЧЕНИЕ(Перечисление.ВариантыПриемкиТоваров.РазделенаТолькоПоНакладным)
		|				ИЛИ НЕ ТабЧасть.Ссылка.ПеремещениеПоЗаказам
		|				ИЛИ ТабЧасть.КодСтроки = 0)
		|		ИЛИ ТабЧасть.Ссылка.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыПеремещенийТоваров.Отгружено)
		|			И(НЕ ТабЧасть.Ссылка.ПеремещениеПоЗаказам
		|				ИЛИ ТабЧасть.КодСтроки = 0)";
	
	РаспределениеЗапасовДвижения.ЗапланироватьПриходЗапаса(Запрос, ТекстыЗапроса, Регистры, ТекстЗапросаТабЧасть);
	
КонецПроцедуры

Функция гф_ТекстЗапросаТаблицаЗаказыКлиентов(Запрос, ТекстыЗапроса, Регистры)
	ИмяРегистра = "ЗаказыКлиентов";
	
	Если НЕ ПроведениеДокументов.ТребуетсяТаблицаДляДвижений(ИмяРегистра, Регистры) Тогда
		Возврат "";
	КонецЕсли; 
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Расход) КАК ВидДвижения,
	|	ТаблицаТовары.Ссылка.Дата КАК Период,
	|	ПеремещениеТоваров.гф_ЗаказКлиента КАК ЗаказКлиента,
	|	ТаблицаТовары.Номенклатура КАК Номенклатура,
	|	ТаблицаТовары.Характеристика КАК Характеристика,
	|	ВЫБОР
	|		КОГДА ТаблицаТовары.СтатусУказанияСерий В (10, 14)
	|			ТОГДА ТаблицаТовары.Серия
	|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.СерииНоменклатуры.ПустаяСсылка)
	|	КОНЕЦ КАК Серия,
	|	ТаблицаТовары.КодСтроки КАК КодСтроки,
	|	ЗНАЧЕНИЕ(Справочник.Склады.ПустаяСсылка) КАК Склад,
	|	0 КАК Заказано,
	|	ТаблицаТовары.Количество КАК КОформлению,
	|	0 КАК Сумма
	|ИЗ
	|	Документ.ПеремещениеТоваров.Товары КАК ТаблицаТовары
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПеремещениеТоваров КАК ПеремещениеТоваров
	|		ПО ТаблицаТовары.Ссылка = ПеремещениеТоваров.Ссылка
	|ГДЕ
	|	ТаблицаТовары.Ссылка = &Ссылка
	|	И ТаблицаТовары.КодСтроки <> 0
	|	И &Статус <> ЗНАЧЕНИЕ(Перечисление.СтатусыПеремещенийТоваров.Принято)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Расход),
	|	ТаблицаТовары.Ссылка.Дата,
	|	ПеремещениеТоваров.гф_ЗаказКлиента,
	|	ТаблицаТовары.Номенклатура,
	|	ТаблицаТовары.Характеристика,
	|	ВЫБОР
	|		КОГДА ТаблицаТовары.СтатусУказанияСерий В (10, 14)
	|			ТОГДА ТаблицаТовары.Серия
	|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.СерииНоменклатуры.ПустаяСсылка)
	|	КОНЕЦ,
	|	ТаблицаТовары.КодСтроки,
	|	ЗНАЧЕНИЕ(Справочник.Склады.ПустаяСсылка),
	|	ТаблицаТовары.Количество,
	|	ТаблицаТовары.Количество,
	|	0
	|ИЗ
	|	Документ.ПеремещениеТоваров.Товары КАК ТаблицаТовары
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПеремещениеТоваров КАК ПеремещениеТоваров
	|		ПО ТаблицаТовары.Ссылка = ПеремещениеТоваров.Ссылка
	|ГДЕ
	|	ТаблицаТовары.Ссылка = &Ссылка
	|	И ТаблицаТовары.КодСтроки <> 0
	|	И &Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыПеремещенийТоваров.Принято)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Приход),
	|	ТаблицаТовары.Ссылка.Дата,
	|	ПеремещениеТоваров.гф_ЗаказКлиента,
	|	ТаблицаТовары.Номенклатура,
	|	ТаблицаТовары.Характеристика,
	|	ВЫБОР
	|		КОГДА ТаблицаТовары.СтатусУказанияСерий В (10, 14)
	|			ТОГДА ТаблицаТовары.Серия
	|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.СерииНоменклатуры.ПустаяСсылка)
	|	КОНЕЦ,
	|	ТаблицаТовары.КодСтроки,
	|	ЗНАЧЕНИЕ(Справочник.Склады.ПустаяСсылка),
	|	0,
	|	ТаблицаТовары.Количество,
	|	0
	|ИЗ
	|	Документ.ПеремещениеТоваров.Товары КАК ТаблицаТовары
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПеремещениеТоваров КАК ПеремещениеТоваров
	|		ПО ТаблицаТовары.Ссылка = ПеремещениеТоваров.Ссылка
	|ГДЕ
	|	ТаблицаТовары.Ссылка = &Ссылка
	|	И ТаблицаТовары.КодСтроки = 0
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Расход),
	|	ТаблицаТовары.Ссылка.Дата,
	|	ПеремещениеТоваров.гф_ЗаказКлиента,
	|	ТаблицаТовары.Номенклатура,
	|	ТаблицаТовары.Характеристика,
	|	ВЫБОР
	|		КОГДА ТаблицаТовары.СтатусУказанияСерий В (10, 14)
	|			ТОГДА ТаблицаТовары.Серия
	|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.СерииНоменклатуры.ПустаяСсылка)
	|	КОНЕЦ,
	|	ТаблицаТовары.КодСтроки,
	|	ЗНАЧЕНИЕ(Справочник.Склады.ПустаяСсылка),
	|	0,
	|	ТаблицаТовары.Количество,
	|	ТаблицаТовары.СуммаВзаиморасчетов
	|ИЗ
	|	Документ.РеализацияТоваровУслуг.Товары КАК ТаблицаТовары
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПеремещениеТоваров КАК ПеремещениеТоваров
	|		ПО ТаблицаТовары.Ссылка = ПеремещениеТоваров.Ссылка
	|ГДЕ
	|	ТаблицаТовары.Ссылка = &Ссылка
	|	И ТаблицаТовары.КодСтроки = 0";
	
	ТекстыЗапроса.Добавить(ТекстЗапроса, ИмяРегистра);
	Возврат ТекстЗапроса;
	
КонецФункции

Функция гф_ПолучитьКодКлиента(Склад, КодНайден)
	
	// ++ Галфинд ВолковЕВ 08.06.2023 нет такого регистра как в УПП
	//запись = РегистрыСведений.ЗначенияСвойствОбъектов.СоздатьМенеджерЗаписи();
	//запись.Объект = Склад;
	//запись.Свойство = Справочники.B2B_w_Настройки.СвойствоКодКлиентаHellmann.Значение;
	//запись.Прочитать();
	//Если запись.Выбран() Тогда
	//	КодКлиента = запись.Значение;
	//	КодНайден = Истина;
	//Иначе
		КодКлиента = СокрЛП(Справочники.B2B_w_Настройки.ОбменДаннымиКодКлиента.Значение);
		КодНайден = Ложь;
	//КонецЕсли;
	
	КодКлиента = СокрЛП(Справочники.B2B_w_Настройки.ОбменДаннымиКодКлиента.Значение);
	КодНайден = Ложь;
	// -- Галфинд ВолковЕВ 08.06.2023
	
	Возврат КодКлиента;
	
КонецФункции

#КонецЕсли