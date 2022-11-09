﻿//////РЕГИСТРАЦИЯ ОТЧЕТА
Функция СведенияОВнешнейОбработке() Экспорт
    
    ИмяОтчета = ЭтотОбъект.Метаданные().Имя; 
    Синоним = ЭтотОбъект.Метаданные().Синоним; 
    Синоним = ?(ЗначениеЗаполнено(Синоним),Синоним, ИмяОтчета);         
    РегистрационныеДанные = Новый Структура;
    РегистрационныеДанные.Вставить("Вид","ДополнительныйОтчет"); //может быть – ПечатнаяФорма, ЗаполнениеОбъекта (для вн.обработки), ДополнительныйОтчет, СозданиеСвязанныхОбъектов… 
    РегистрационныеДанные.Вставить("Наименование", Синоним); //имя под которым обработка будет зарегестрирована в справочнике внешних обработок
    РегистрационныеДанные.Вставить("Версия", "1.0");
    РегистрационныеДанные.Вставить("БезопасныйРежим", Ложь);
    РегистрационныеДанные.Вставить("Информация", "Отчет "+Синоним); //так будет выглядеть описание вн.отчета для пользователя
    
    ТаблицаКоманд = ПолучитьТаблицуКоманд();
    
    // Добавим команду в таблицу
    ДобавитьКоманду(ТаблицаКоманд, Синоним, "СформироватьОтчет" , "ОткрытиеФормы", Истина, );
        
    // Сохраним таблицу команд в параметры регистрации обработки
    РегистрационныеДанные.Вставить("Команды", ТаблицаКоманд);
    
    Возврат РегистрационныеДанные;
                                       
КонецФункции

Функция ПолучитьТаблицуКоманд()
    
    // Создадим пустую таблицу команд и колонки в ней
    Команды = Новый ТаблицаЗначений;

    // Как будет выглядеть описание печатной формы для пользователя
    Команды.Колонки.Добавить("Представление", Новый ОписаниеТипов("Строка")); 

    // Имя нашего макета, что бы могли отличить вызванную команду в обработке печати
    Команды.Колонки.Добавить("Идентификатор", Новый ОписаниеТипов("Строка"));

    // Тут задается, как должна вызваться команда обработки
    // Возможные варианты:
    // - ОткрытиеФормы - в этом случае в колонке идентификатор должно быть указано имя формы, которое должна будет открыть система
    // - ВызовКлиентскогоМетода - вызвать клиентскую экспортную процедуру из модуля формы обработки
    // - ВызовСерверногоМетода - вызвать серверную экспортную процедуру из модуля объекта обработки
    Команды.Колонки.Добавить("Использование", Новый ОписаниеТипов("Строка"));

    // Следующий параметр указывает, необходимо ли показывать оповещение при начале и завершению работы обработки. Не имеет смысла при открытии формы
    Команды.Колонки.Добавить("ПоказыватьОповещение", Новый ОписаниеТипов("Булево"));

    // Для печатной формы должен содержать строку ПечатьMXL 
    Команды.Колонки.Добавить("Модификатор", Новый ОписаниеТипов("Строка"));
    Возврат Команды;
   
КонецФункции

Процедура ДобавитьКоманду(ТаблицаКоманд, Представление, Идентификатор, Использование = "ОткрытиеФормы", ПоказыватьОповещение = Ложь, Модификатор = "ПечатьMXL")
    
    // Добавляем команду в таблицу команд по переданному описанию.
    // Параметры и их значения можно посмотреть в функции ПолучитьТаблицуКоманд
    НоваяКоманда = ТаблицаКоманд.Добавить();
    НоваяКоманда.Представление = Представление;
    НоваяКоманда.Идентификатор = Идентификатор;
    НоваяКоманда.Использование = Использование;
    НоваяКоманда.ПоказыватьОповещение = ПоказыватьОповещение;
    НоваяКоманда.Модификатор = Модификатор;

КонецПроцедуры 
/////

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
			
	ТипЦеныЗакупочная = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту(
								"Ключ", "гф_ГлобальныеЗначенияОптоваяЗакупочнаяЦена").Значение; 
	ТипЦеныРозничная = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту(
								"Ключ", "гф_ГлобальныеЗначенияРозничнаяЦена").Значение;
	
	//СписокСвойствНоменклатуры = СформироватьСписокСвойсвНоменклатуры();
	//СписокДопИнформации = Сформировать
	
	СписокДокументов = Новый СписокЗначений;
	ПараметрыОтбора = новый Структура;
	ПараметрыОтбора.Вставить("Пометка",Истина);
	НайденныеСтроки = ТаблицаДокументы.НайтиСтроки(ПараметрыОтбора);
	
	Для каждого СтрокаДокумента из НайденныеСтроки Цикл
		СписокДокументов.Добавить(СтрокаДокумента.Документ);
	КонецЦикла;	
	
	
	
	
	//Запрос = новый Запрос;
	//Запрос.УстановитьПараметр("СписокДокументов",СписокДокументов);
	//
	//Если Вид = "РеализацииПокупателей" Тогда
	//	
	//	 //ЗапросПоНоменклатуре = ЗапросПоНоменклатуре_РеализацииПокупателей();
	//	 //ЗапросПоИнформацииНоменклатуре = ЗапросПоИнформацииНоменклатуре(); 
	// ИначеЕсли Вид = "ПриобретениеТоваровИУслуг" Тогда
	//	 
	//	 ЗапросПоНоменклатуре =  ЗапросПоНоменклатуре_ПриобретениеТоваровИУслуг();
	//	 Запрос.Текст = ЗапросПоНоменклатуре;
	//	 
	//ИначеЕсли Вид = "ЗаказыКлиентов" Тогда	
	//	 ЗапросПоНоменклатуре = ЗапросПоНоменклатуре_ЗаказыКлиентов();
	//	 Запрос.Текст = ЗапросПоНоменклатуре;
	// ИначеЕсли Вид = "ВнутренниеЗаказы" Тогда
	//	 ЗапросПоНоменклатуре = ЗапросПоНоменклатуре_ВнутренниеЗаказы();
	//	 Запрос.Текст = ЗапросПоНоменклатуре;		 
	//КонецЕсли;	
	
	
	//Результат = Запрос.Выполнить().Выгрузить();
	
	//ДополнитьСвойствамиНоменклатуры(Результат, СписокСвойствНоменклатуры);
	//ДополнитьДополнительнойИнформацией(Результат);
	//Если ФормироватьВПарах Тогда
	//	СхемаКомпоновкиДанных = ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанных");
	//Иначе
	СхемаКомпоновкиДанных = ПолучитьИзВременногоХранилища(АдресСхемы); 
	КомпоновщикНастроек.ЗагрузитьПользовательскиеНастройки(КомпоновщикОтбораНоменклатуры.ПользовательскиеНастройки);
	//КонецЕсли;
	//КомпоновщикНастроек.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	//КомпоновщикНастроек.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	//ПользовательскиеНастройки = КомпоновщикНастроек.ПользовательскиеНастройки;
	//КомпоновщикНастроек.ЗагрузитьПользовательскиеНастройки(ПользовательскиеНастройки);
	Настройки = КомпоновщикНастроек.ПолучитьНастройки(); 
	//Если Вид = "Ассортимент" Тогда
	//	Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("КонецПериода", КонецПериода);
	//	Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ВидЦеныЗакупочная", ТипЦеныЗакупочная);
	//	Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ВидЦеныРозничная", ТипЦеныРозничная);
	//Иначе	
	ПараметрВидЦеныСоСкидкой = Настройки.ПараметрыДанных.Элементы.Найти("ВидЦенСоСкидкой");
	
	Если ПараметрВидЦеныСоСкидкой <> неопределено Тогда
		Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ВидЦенСоСкидкой", ТипЦенСоСкидкой);
	КонецЕсли;
	
	ПараметрСписокДокументов = Настройки.ПараметрыДанных.Элементы.Найти("СписокДокументов");		
	
	Если ПараметрСписокДокументов <> неопределено Тогда
		Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("СписокДокументов", СписокДокументов);
	КонецЕсли;	
	
	ПараметрКонецПериода = Настройки.ПараметрыДанных.Элементы.Найти("КонецПериода");
	
	ГраницаКонецПериода = новый Граница(КонецПериода, ВидГраницы.Включая);
	
	Если ПараметрКонецПериода <> неопределено Тогда
		Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("КонецПериода", 
								?(ЗначениеЗаполнено(КонецПериода),ГраницаКонецПериода,КонецДня(ТекущаяДатаСеанса())));
	КонецЕсли;
	
	
	//
	//ПараметрВидЦеныРозничная = Настройки.ПараметрыДанных.Элементы.Найти("ВидЦенРозничная");
	//
	//Если ПараметрВидЦеныРозничная <> неопределено Тогда
	//	Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ВидЦенРозничная", ТипЦеныРозничная);
	//КонецЕсли;
	
	ПараметрОрганизация = Настройки.ПараметрыДанных.Элементы.Найти("Организация");
	
	Если ПараметрОрганизация <> неопределено Тогда
		Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("Организация", Организация);
	КонецЕсли;
	
	ПараметрСклад = Настройки.ПараметрыДанных.Элементы.Найти("Склад"); 
	
	Если ПараметрСклад <> неопределено Тогда
		Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("Склад", СкладПолучатель);
	КонецЕсли;
	
	// ++ СадомцевСА 30.09.2022
	ПараметрДопРеквизитТоварыВКоробах = Настройки.ПараметрыДанных.Элементы.Найти("ДопРеквизитТоварыВКоробах");
	Если ПараметрДопРеквизитТоварыВКоробах <> Неопределено Тогда
		Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ДопРеквизитТоварыВКоробах", ДопРеквизитТоварыВКоробах);
	КонецЕсли;
	// -- СадомцевСА 30.09.2022
	
	//Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("СписокДокументов", СписокДокументов);
	//Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ВПарах", ФормироватьВПарах);
	//Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ВКоробах", не ФормироватьВПарах);
	//Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("КонецПериода", КонецПериода);
	//Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("Организация", Организация);
	//Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ВидЦеныЗакупочная", ТипЦеныЗакупочная);  
	//Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ВидЦеныРозничная", ТипЦеныРозничная);
	//Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ВнутренниеЗаказы", Вид = "ВнутренниеЗаказы");
	//Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("СвободныеОстатки", Вид = "СвободныеОстатки"); 
	//Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("Склад", СкладПолучатель); 
	//КонецЕсли;
	
	КомпоновщикНастроек.ЗагрузитьНастройки(Настройки);
	
	//Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	//
	//ВнешниеНаборыДанных = Новый Структура;
	//ВнешниеНаборыДанных.Вставить("ТаблицаДанныхОтчета", Результат);
	
	
	ДанныеРасшифровки = Новый ДанныеРасшифровкиКомпоновкиДанных;
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетОформления = новый  МакетОформленияКомпоновкиДанных() ;
		
	//МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, КомпоновщикНастроек.Настройки, ДанныеРасшифровки,МакетОформления);
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, КомпоновщикНастроек.Настройки, ДанныеРасшифровки,МакетОформления);	
	
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновки, ,ДанныеРасшифровки, Истина );
	
	ДокументРезультат.Очистить();
		
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);  
		
	Область = ДокументРезультат.НайтиТекст("№ п/п");
	Если Область <> неопределено Тогда
		ШиринаТаблицы = ДокументРезультат.ШиринаТаблицы;
		ИмяСтроки = "R1"+"C"+Строка(ШиринаТаблицы);
		
		ДокументРезультат.Область(Область.Верх,Область.Лево, Область.Низ ,ШиринаТаблицы).ЦветФона = новый Цвет(255,255,153)
	КонецЕсли;	
	
	Область = ДокументРезультат.НайтиТекст("200 (36-40)");
	Если Область <> неопределено Тогда
		ШиринаТаблицы = ДокументРезультат.ШиринаТаблицы;
		ИмяСтроки = "R1"+"C"+Строка(ШиринаТаблицы);
		
		ДокументРезультат.Область(Область.Верх,Область.Лево, Область.Низ ,ШиринаТаблицы-3).ЦветФона = новый Цвет(255,255,255)
	КонецЕсли;
	
КонецПроцедуры

Процедура ДополнитьСвойствамиНоменклатуры(ТаблицаНоменклатур, СписокСвойствНоменклатуры)
	
	Для каждого СвойствоНоменклатуры из СписокСвойствНоменклатуры Цикл
		ИмяКолонки = СвойствоНоменклатуры.Значение;
		ИмяСвойства = СвойствоНоменклатуры.Представление;
		ТаблицаНоменклатур.Колонки.Добавить(ИмяКолонки);
		
		Для Каждого Строка из ТаблицаНоменклатур Цикл
			
			ЗначениеСвойства = УправлениеСвойствами.ЗначениеСвойства(Строка.Номенклатура, ИмяСвойства);
			Строка[ИмяКолонки] = ЗначениеСвойства;
			
		КонецЦикла;	
		
	КонецЦикла;	
	
	
КонецПроцедуры	

Процедура ДополнитьДополнительнойИнформацией(ТаблицаНоменклатур)
	
	ТипЦеныЗакупочная = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту(
								"Ключ", "гф_ГлобальныеЗначенияОптоваяЗакупочнаяЦена").Значение; 
	ТипЦеныРозничная = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту(
								"Ключ", "гф_ГлобальныеЗначенияРозничнаяЦена").Значение;
	//Цвет
	ТаблицаНоменклатур.Колонки.Добавить("Цвет");
	ТаблицаНоменклатур.Колонки.Добавить("Штрихкод");
	ТаблицаНоменклатур.Колонки.Добавить("ШтрихкодКороба");
	//ТаблицаНоменклатур.Колонки.Добавить("КодНоменклатурыКонтрагента");
	ТаблицаНоменклатур.Колонки.Добавить("ЦенаЗаПару"); 
	
	ТаблицаНоменклатур.Колонки.Добавить("РозничнаяЦена");
	//ТаблицаНоменклатур.Колонки.Добавить("КодТНВЭД");
	ТаблицаНоменклатур.Колонки.Добавить("ГТД"); //?
	ТаблицаНоменклатур.Колонки.Добавить("ВидТовара");
	ТаблицаНоменклатур.Колонки.Добавить("Пол"); //?
	ТаблицаНоменклатур.Колонки.Добавить("Возраст"); //?
	ТаблицаНоменклатур.Колонки.Добавить("СтавкаНДС");
	ТаблицаНоменклатур.Колонки.Добавить("ДоступныеРостовки"); 
	ТаблицаНоменклатур.Колонки.Добавить("ДатаИзготовления");
	//ТаблицаНоменклатур.Колонки.Добавить("ВариантыКомплектации");
	ТаблицаНоменклатур.Колонки.Добавить("КодНоменклатурыКонтрагента");
	ТаблицаНоменклатур.Колонки.Добавить("СтранаПроисхождения");
	
	ТаблицаНоменклатур.Колонки.Добавить("РазмерныйРяд");
	ТаблицаНоменклатур.Колонки.Добавить("РоссийскийРазмер");
	
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВКоробе_36");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВКоробе_37");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВКоробе_38");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВКоробе_39"); 
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВКоробе_40");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВКоробе_41");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВКоробе_42"); 
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВКоробе_43"); 
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВКоробе_44");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВКоробе_45");
	
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоПарВКоробе");
	
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВсего_36");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВсего_37");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВсего_38");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВсего_39"); 
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВсего_40");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВсего_41");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВсего_42");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВсего_43");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВсего_44");
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоВсего_45");
	
	ТаблицаНоменклатур.Колонки.Добавить("КоличествоПар");
	
	ТаблицаШтрихКодов = ПолучитьШтрихкоды();
	
	Для каждого СтрокаНоменклатуры из ТаблицаНоменклатур Цикл
		
		Отбор = Новый Структура;
		Отбор.Вставить("Номенклатура",СтрокаНоменклатуры.Номенклатура);
		Отбор.Вставить("Характеристика",СтрокаНоменклатуры.Характеристика);
		
		МассивШтрихкодов = РегистрыСведений.ШтрихкодыНоменклатуры.ШтрихкодыНоменклатуры(СтрокаНоменклатуры.Номенклатура,
													СтрокаНоменклатуры.Характеристика,Справочники.УпаковкиЕдиницыИзмерения.ПустаяСсылка());
		СтрокаНоменклатуры.Штрихкод = ?(МассивШтрихкодов.Количество() <> 0,МассивШтрихкодов[0],"");
		
		СтрокаНоменклатуры.ШтрихкодКороба = СтрокаНоменклатуры.УпаковочныйЛист.Код;
		
		Отбор = Новый Структура;
		Отбор.Вставить("Номенклатура", СтрокаНоменклатуры.Номенклатура);	
		Отбор.Вставить("ВидЦены", ТипЦеныЗакупочная);
		
		СтрокаНоменклатуры.ЦенаЗаПару =  РегистрыСведений.ЦеныНоменклатуры25.ПолучитьПоследнее(ТекущаяДатаСеанса(), Отбор).Цена;
		
		Отбор = Новый Структура;
		Отбор.Вставить("Номенклатура", СтрокаНоменклатуры.Номенклатура);	
		Отбор.Вставить("ВидЦены", ТипЦеныРозничная);
		
		СтрокаНоменклатуры.РозничнаяЦена =  РегистрыСведений.ЦеныНоменклатуры25.ПолучитьПоследнее(ТекущаяДатаСеанса(), Отбор).Цена;
		
		Если ЗначениеЗаполнено(СтрокаНоменклатуры.Номенклатура.КодТНВЭД) Тогда
			СтрокаНоменклатуры.КодТНВЭД = СтрокаНоменклатуры.Номенклатура.КодТНВЭД;
		КонецЕсли;
		
		СтрокаНоменклатуры.ВидТовара = СтрРазделить(СтрокаНоменклатуры.Номенклатура.Наименование," ")[0];
		СтрокаНоменклатуры.СтавкаНДС = СтрокаНоменклатуры.Номенклатура.СтавкаНДС;
		
		СтрокаНоменклатуры.ДоступныеРостовки = СформироватьДоступныеРостовки(СтрокаНоменклатуры.Номенклатура);
		
		РасчитатьКоличественныеПоказатели(СтрокаНоменклатуры);
		
		СтрокаНоменклатуры.РазмерныйРяд = СтрокаНоменклатуры.Характеристика.Наименование;
		СтрокаНоменклатуры.РоссийскийРазмер = СтрокаНоменклатуры.Характеристика.Наименование;
		
	КонецЦикла;	
	

КонецПроцедуры	

Процедура РасчитатьКоличественныеПоказатели(СтрокаНоменклатуры)
	
	ВариантКомплектации = СтрокаНоменклатуры.ВариантКомплектации;
	ВсегоПар = 0;
	Для каждого Строка из ВариантКомплектации.Товары Цикл
		
		НаименованиеХарактеристики = Строка.Характеристика.Наименование;
		
		СтрокаНоменклатуры["КоличествоВКоробе_"+НаименованиеХарактеристики] = Строка.Количество;
		СтрокаНоменклатуры["КоличествоВсего_"+НаименованиеХарактеристики] = Строка.Количество * СтрокаНоменклатуры.КоличествоКоробов;
		ВсегоПар = ВсегоПар + Строка.Количество * СтрокаНоменклатуры.КоличествоКоробов;
	КонецЦикла;	
	
	СтрокаНоменклатуры.КоличествоПарВКоробе = ВариантКомплектации.Товары.Итог("Количество");
	СтрокаНоменклатуры.КоличествоПар = ВсегоПар;
	
	
КонецПроцедуры	

Функция СформироватьДоступныеРостовки(Номенклатура) 

	Запрос = новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВариантыКомплектацииНоменклатуры.Характеристика КАК Характеристика
	|ИЗ
	|	Справочник.ВариантыКомплектацииНоменклатуры КАК ВариантыКомплектацииНоменклатуры
	|ГДЕ
	|	ВариантыКомплектацииНоменклатуры.Владелец = &Владелец
	|	И ВариантыКомплектацииНоменклатуры.ПометкаУдаления = ЛОЖЬ
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВариантыКомплектацииНоменклатуры.Характеристика.Наименование";
	
	Запрос.УстановитьПараметр("Владелец", Номенклатура); 
	
	Результат = Запрос.Выполнить().Выбрать();
	
	ДоступныеРастовки = "";
	ПерваяСтрока = Истина; 
	
	Пока Результат.Следующий() Цикл
		Если ПерваяСтрока Тогда
			ДоступныеРастовки = Результат.Характеристика.Наименование;
		Иначе
			ДоступныеРастовки = "," + ДоступныеРастовки; 
		КонецЕсли;
	КонецЦикла;
	
	Возврат ДоступныеРастовки;
КонецФункции

Функция СформироватьСписокСвойсвНоменклатуры()
	
	СписокСвойств = новый СписокЗначений;
	СписокСвойств.Добавить("Марка","Марка");
	СписокСвойств.Добавить("Сезон","Сезон");
	СписокСвойств.Добавить("НомерЦвета","Color_Code");
	//СписокСвойств.Добавить("Цвет","Color_Name");
	СписокСвойств.Добавить("МатериалОсновной","Material");
	СписокСвойств.Добавить("МатериалПодклада","Material lining");
	СписокСвойств.Добавить("МатериалПодкладаДополнительно","Material warmlining");
	СписокСвойств.Добавить("МатериалВерха","Material surface");
	СписокСвойств.Добавить("Стелька","Material back");
	СписокСвойств.Добавить("Подошва","Material bottom");
	СписокСвойств.Добавить("Комплектующая","Customer brand");
	СписокСвойств.Добавить("Коллекция","Supplier_season");
	СписокСвойств.Добавить("ВысотаКаблука","Heel height");
	СписокСвойств.Добавить("Декларация","Декларация");
	СписокСвойств.Добавить("ВидЗастежки","ClossingForm");
	СписокСвойств.Добавить("ВысотаГоленища","LEGHEIGHT");
	СписокСвойств.Добавить("ОбхватГоленища","LEGFUNCT");
	СписокСвойств.Добавить("ВидКаблука","HEELTYP");
	СписокСвойств.Добавить("ФормаИВидМыска","TOE-CAP");
	СписокСвойств.Добавить("ШиринаПолнота","Wideness");
	//СписокСвойств.Добавить("ДатаИзготовления","Представление");
	СписокСвойств.Добавить("Технология","Function");
	
	СписокСвойств.Добавить("КодТНВЭД","Customs_tarif_number");
	//СписокСвойств.Добавить("Значение","Представление");
	//СписокСвойств.Добавить("Значение","Представление");
	//СписокСвойств.Добавить("Значение","Представление");
	//СписокСвойств.Добавить("Значение","Представление");
	//СписокСвойств.Добавить("Значение","Представление");
	//СписокСвойств.Добавить("Значение","Представление");
	Возврат СписокСвойств;
КонецФункции	

Функция ЗапросПоНоменклатуре_РеализацииПокупателей()
	
	ТекстЗапроса =
	"";
	
	
КонецФункции	

Функция ЗапросПоНоменклатуре_ЗаказыКлиентов()
	
	Если ФормироватьВПарах Тогда
		ТекстЗапроса = 
		"ВЫБРАТЬ
		|	ЗаказКлиентаТовары.Номенклатура КАК Номенклатура,
		|	МИНИМУМ(ЗаказКлиентаТовары.Цена) КАК Цена,
		|	ЗаказКлиентаТовары.Номенклатура.Качество КАК Качество,
		|	ЗаказКлиентаТовары.Количество КАК Количество,
		|	ЗаказКлиентаТовары.Характеристика КАК Характеристика,
		|	ЗНАЧЕНИЕ(Документ.УпаковочныйЛист.ПустаяСсылка) КАК УпаковочныйЛист,
		|	ЗаказКлиентаТовары.Цена * (ЗаказКлиентаТовары.ПроцентРучнойСкидки / 100) * (ЗаказКлиентаТовары.ПроцентАвтоматическойСкидки / 100) КАК ЦенаСоСкидкойБезНДС,
		|	ЗаказКлиентаТовары.Цена * (ЗаказКлиентаТовары.ПроцентРучнойСкидки / 100) * (ЗаказКлиентаТовары.ПроцентАвтоматическойСкидки / 100) КАК ЦенаСоСкидкойСНДС,
		|	ЗНАЧЕНИЕ(Справочник.ВариантыКомплектацииНоменклатуры.ПустаяСсылка) КАК ВариантКомплектации,
		|	0 КАК КоличествоКоробов
		|ИЗ
		|	Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
		|ГДЕ
		|	ЗаказКлиентаТовары.Ссылка В(&СписокДокументов)
		|
		|СГРУППИРОВАТЬ ПО
		|	ЗаказКлиентаТовары.Номенклатура,
		|	ЗаказКлиентаТовары.Номенклатура.Качество,
		|	ЗаказКлиентаТовары.Количество,
		|	ЗаказКлиентаТовары.Характеристика,
		|	ЗаказКлиентаТовары.Цена * (ЗаказКлиентаТовары.ПроцентРучнойСкидки / 100) * (ЗаказКлиентаТовары.ПроцентАвтоматическойСкидки / 100),
		|	ЗаказКлиентаТовары.Цена * (ЗаказКлиентаТовары.ПроцентРучнойСкидки / 100) * (ЗаказКлиентаТовары.ПроцентАвтоматическойСкидки / 100)";  
	Иначе
		ТекстЗапроса = 
		"ВЫБРАТЬ
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации.Владелец КАК Номенклатура,
		|	МИНИМУМ(ЗаказКлиентагф_ТоварыВКоробах.ЦенаКороба) КАК Цена,
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации.Владелец.Качество КАК Качество,
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации КАК ВариантКомплектации,
		|	ЗаказКлиентагф_ТоварыВКоробах.IDКороба КАК УпаковочныйЛист,
		|	СУММА(ЗаказКлиентагф_ТоварыВКоробах.Количество) КАК КоличествоКоробов,
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации.Характеристика КАК Характеристика,
		|	0 КАК ЦенаСоСкидкойБезНДС,
		|	0 КАК ЦенаСоСкидкойСНДС
		|ИЗ
		|	Документ.ЗаказКлиента.гф_ТоварыВКоробах КАК ЗаказКлиентагф_ТоварыВКоробах
		|ГДЕ
		|	ЗаказКлиентагф_ТоварыВКоробах.Ссылка В(&СписокДокументов)
		|
		|СГРУППИРОВАТЬ ПО
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации.Владелец,
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации.Владелец.Качество,
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации,
		|	ЗаказКлиентагф_ТоварыВКоробах.IDКороба,
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации.Характеристика";
	КонецЕсли; 
	
	Возврат ТекстЗапроса;
	
КонецФункции	

Функция ЗапросПоНоменклатуре_ПриобретениеТоваровИУслуг()
	
	 Если ФормироватьВПарах Тогда
		ТекстЗапроса = 
		"ВЫБРАТЬ
		|	ЗаказКлиентаТовары.Номенклатура КАК Номенклатура,
		|	МИНИМУМ(ЗаказКлиентаТовары.Цена) КАК ЦенаСоСкидкойСНДС,
		|	ЗаказКлиентаТовары.Номенклатура.Качество КАК Качество
		|ИЗ
		|	Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
		|ГДЕ
		|	ЗаказКлиентаТовары.Ссылка В(&СписокДокументов)
		|
		|СГРУППИРОВАТЬ ПО
		|	ЗаказКлиентаТовары.Номенклатура,
		|	ЗаказКлиентаТовары.Номенклатура.Качество";  
	Иначе
		ТекстЗапроса = 
		"ВЫБРАТЬ
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации.Владелец КАК Номенклатура,
		|	МИНИМУМ(ЗаказКлиентагф_ТоварыВКоробах.ЦенаКороба) КАК Цена,
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации.Владелец.Качество КАК Качество,
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации КАК ВариантКомплектации,
		|	ЗаказКлиентагф_ТоварыВКоробах.IDКороба КАК УпаковочныйЛист
		|ИЗ
		|	Документ.ЗаказКлиента.гф_ТоварыВКоробах КАК ЗаказКлиентагф_ТоварыВКоробах
		|ГДЕ
		|	ЗаказКлиентагф_ТоварыВКоробах.Ссылка В(&СписокДокументов)
		|
		|СГРУППИРОВАТЬ ПО
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации.Владелец,
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации.Владелец.Качество,
		|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации,
		|	ЗаказКлиентагф_ТоварыВКоробах.IDКороба";
	КонецЕсли; 
	
	Возврат ТекстЗапроса;

	
КонецФункции

Функция ЗапросПоНоменклатуре_ВнутренниеЗаказы()
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	ВнутреннееПотреблениеТоваровТовары.Номенклатура КАК Номенклатура,
	|	ВнутреннееПотреблениеТоваровТовары.Количество КАК Количество
	|ИЗ
	|	Документ.ВнутреннееПотреблениеТоваров.Товары КАК ВнутреннееПотреблениеТоваровТовары
	|ГДЕ
	|	ВнутреннееПотреблениеТоваровТовары.Ссылка = &СписокДокументов";
	
	Возврат ТекстЗапроса;
	
КонецФункции	

Функция ЗапросПоИнформацииНоменклатуре()
	
	Текст = 
	"ВЫБРАТЬ
	|	НоменклатураДополнительныеРеквизиты.Ссылка КАК Номенклатура,
	|	НоменклатураДополнительныеРеквизиты.Значение КАК Марка
	|ПОМЕСТИТЬ СвойствоМарка
	|ИЗ
	|	Справочник.Номенклатура.ДополнительныеРеквизиты КАК НоменклатураДополнительныеРеквизиты
	|ГДЕ
	|	НоменклатураДополнительныеРеквизиты.Свойство = &СвойствоМарка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НоменклатураДополнительныеРеквизиты.Ссылка КАК Номенклатура,
	|	НоменклатураДополнительныеРеквизиты.Значение КАК Сезон
	|ПОМЕСТИТЬ СвойствоСезон
	|ИЗ
	|	Справочник.Номенклатура.ДополнительныеРеквизиты КАК НоменклатураДополнительныеРеквизиты
	|ГДЕ
	|	НоменклатураДополнительныеРеквизиты.Свойство = &СвойствоСезон
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НоменклатураДополнительныеРеквизиты.Ссылка КАК Номенклатура,
	|	НоменклатураДополнительныеРеквизиты.Значение КАК НомерЦвета
	|ПОМЕСТИТЬ СвойствоНомерЦвета
	|ИЗ
	|	Справочник.Номенклатура.ДополнительныеРеквизиты КАК НоменклатураДополнительныеРеквизиты
	|ГДЕ
	|	НоменклатураДополнительныеРеквизиты.Свойство = &СвойствоНомерЦвета
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НоменклатураДополнительныеРеквизиты.Ссылка КАК Номенклатура,
	|	НоменклатураДополнительныеРеквизиты.Значение КАК Цвет
	|ПОМЕСТИТЬ СвойствоЦвет
	|ИЗ
	|	Справочник.Номенклатура.ДополнительныеРеквизиты КАК НоменклатураДополнительныеРеквизиты
	|ГДЕ
	|	НоменклатураДополнительныеРеквизиты.Свойство = &СвойствоЦвет
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НоменклатураДополнительныеРеквизиты.Ссылка КАК Номенклатура,
	|	НоменклатураДополнительныеРеквизиты.Значение КАК МатериалОсновной
	|ПОМЕСТИТЬ СвойствоМатериалОсновной
	|ИЗ
	|	Справочник.Номенклатура.ДополнительныеРеквизиты КАК НоменклатураДополнительныеРеквизиты
	|ГДЕ
	|	НоменклатураДополнительныеРеквизиты.Свойство = &СвойствоМатериалОсновной";
	
КонецФункции	

Функция ПолучитьШтрихкоды()
	
	Запрос = новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ШтрихкодыНоменклатуры.Штрихкод КАК Штрихкод,
	|	ШтрихкодыНоменклатуры.Номенклатура КАК Номенклатура,
	|	ШтрихкодыНоменклатуры.Характеристика КАК Характеристика
	|ИЗ
	|	РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры";
		 	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции	

Процедура УстановитьПараметрыСКД() Экспорт
	
	ТипЦеныЗакупочная = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту(
								"Ключ", "гф_ГлобальныеЗначенияОптоваяЗакупочнаяЦена").Значение; 
	ТипЦеныРозничная = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту(
								"Ключ", "гф_ГлобальныеЗначенияРозничнаяЦена").Значение;
	
	
	
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	
	ПараметрВидЦеныЗакупочная = Настройки.ПараметрыДанных.Элементы.Найти("ВидЦенЗакупочная");
	
	Если ПараметрВидЦеныЗакупочная <> неопределено Тогда
		Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ВидЦенЗакупочная", ТипЦеныЗакупочная);
	КонецЕсли;
	
	ПараметрВидЦеныРозничная = Настройки.ПараметрыДанных.Элементы.Найти("ВидЦенРозничная");
	
	Если ПараметрВидЦеныРозничная <> неопределено Тогда
		Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ВидЦенРозничная", ТипЦеныРозничная);
	КонецЕсли;
			
	КомпоновщикНастроек.ЗагрузитьНастройки(Настройки);
КонецПроцедуры	
//Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
//	// Вставить содержимое обработчика.
//КонецПроцедуры

