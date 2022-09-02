﻿
#Область ОбработчикиСобытийФормы  

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	гф_СоздатьНовыеРеквизиты();
	
	Если ЗначениеЗаполнено(Объект.Склад) Тогда 
         ВидимостьСтраницыТоварыВКоробах();
	Иначе
		 Элементы.гф_СтраницаТоварыВКоробах.Видимость = Ложь;
	КонецЕсли; 
	гф_УстановитьУсловноеОформление(); 
КонецПроцедуры  

&НаКлиенте
Процедура гф_ОбработкаВыбораПосле(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ИсточникВыбора.ИмяФормы = "Справочник.гф_АдресаДоставки.Форма.ФормаВыбора" Тогда
		
		Адрес =  ПолучитьЗначениеРеквизита(ВыбранноеЗначение, "Адрес");
		АдресЗначение = ПолучитьЗначениеРеквизита(ВыбранноеЗначение, "Значение");
		АдресЗначенияПолей = " ";
		
		ИмяРеквизитаАдресаДоставки = ДоставкаТоваровКлиентСервер.ПолучитьИмяРеквизитаАдресаДоставки(ТекущийЭлемент);
		
		Объект[ИмяРеквизитаАдресаДоставки] = Адрес;
		Объект[ИмяРеквизитаАдресаДоставки + "Значение"] = АдресЗначение;
		Объект[ИмяРеквизитаАдресаДоставки + "ЗначенияПолей"] = АдресЗначенияПолей;
				
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
&ИзменениеИКонтроль("АдресДоставкиНачалоВыбора")
Процедура гф_АдресДоставкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
    #Вставка
	СтандартнаяОбработка = Ложь;

	ИмяРеквизитаАдресаДоставки = ДоставкаТоваровКлиентСервер.ПолучитьИмяРеквизитаАдресаДоставки(ТекущийЭлемент);
	
	ПараметрыФормы = Новый Структура;
	
	Если ИмяРеквизитаАдресаДоставки = "АдресДоставкиПеревозчика" Тогда
		
		КонтрагентПеревозчик = ПартнерыИКонтрагентыВызовСервера.КонтрагентПартнера(Объект.ПеревозчикПартнер); 
		ЗначениеОтбора = Новый Структура("Владелец", КонтрагентПеревозчик);		
		ПараметрыФормы.Вставить("Отбор", ЗначениеОтбора);		
		
	Иначе
		ЗначениеОтбора = Новый Структура("Владелец", Объект.Контрагент);
		ПараметрыФормы.Вставить("Отбор", ЗначениеОтбора);
	    	
	КонецЕсли;	
		
	ОткрытьФорму("Справочник.гф_АдресаДоставки.Форма.ФормаВыбора", ПараметрыФормы, ЭтотОбъект);
		
	#КонецВставки
	#Удаление
	ИмяРеквизитаАдресаДоставки = ДоставкаТоваровКлиентСервер.ПолучитьИмяРеквизитаАдресаДоставки(Элемент);

	ДоставкаТоваровКлиент.ОткрытьФормуВыбораАдресаИОбработатьРезультат(
	Элемент,
	Объект,
	ИмяРеквизитаАдресаДоставки,
	СтандартнаяОбработка);
    #КонецУдаления
КонецПроцедуры

&НаКлиенте
Процедура гф_ТоварыВКоробахКоличествоЦенаПриИзменении(Элемент)
	
	ТекущаяСтрока = Элементы.гф_ТаблицаТоварыВКоробах.ТекущиеДанные;
	РассчитатьСтрокуНаСервере(ТекущаяСтрока.ПолучитьИдентификатор());	
	
КонецПроцедуры	

&НаКлиенте
Процедура гф_ТоварыВКоробахПриОкончанииРедактирования(Элемент, НоваяСтрока, Копирование)
	//ЗаполнитьТоварыНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура гф_ТоварыВКоробахДобавленоПриИзменении(Элемент)
	
	ТекущаяСтрока = Элементы.гф_ТаблицаТоварыВКоробах.ТекущиеДанные;
	
	Если Не ТекущаяСтрока.Добавлено Тогда
		ТекущаяСтрока.ПричинаДобавления = ПредопределенноеЗначение("Справочник.ПричиныОтменыЗаказовКлиентов.ПустаяСсылка");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура гф_ТоварыВКоробахОтмененоПриИзменении(Элемент) 
	
	ТекущаяСтрока = Элементы.гф_ТаблицаТоварыВКоробах.ТекущиеДанные;
	
	Если Не ТекущаяСтрока.Отменено Тогда
		ТекущаяСтрока.ПричинаОтмены = ПредопределенноеЗначение("Справочник.ПричиныОтменыЗаказовКлиентов.ПустаяСсылка");
	КонецЕсли;                                           
	
КонецПроцедуры 

&НаКлиенте
Процедура гф_ТоварыДобавленоПриИзменении(Элемент) 
	
	ТекущаяСтрока = Элементы.Товары.ТекущиеДанные;
	
	Если Не ТекущаяСтрока.гф_ДобавленоПоПричине Тогда
		ТекущаяСтрока.гф_ПричинаДобавления = ПредопределенноеЗначение("Справочник.ПричиныОтменыЗаказовКлиентов.ПустаяСсылка");
	КонецЕсли;                                           
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура гф_СоздатьНовыеРеквизиты()
	
	КвалификаторыСтроки	= Новый КвалификаторыСтроки(256);
	КвалификаторыДаты 	= Новый КвалификаторыДаты(ЧастиДаты.Дата);	
	
	ОписаниеТиповСтатусДокумента		= Новый ОписаниеТипов("ПеречислениеСсылка.гф_СтатусРаботыСЗаказомИ5");
	ОписаниеТиповВ2ВСтатуса				= Новый ОписаниеТипов("ПеречислениеСсылка.гф_В2ВСтатус");
	ОписаниеТиповСтрока 				= Новый ОписаниеТипов("Строка", , КвалификаторыСтроки); 
	ОписаниеТиповДата 	 				= Новый ОписаниеТипов("Дата", , , , , КвалификаторыДаты); 
	
	ДобавляемыеРеквизиты = Новый Массив;
	
	РеквизитФормы_гф_СтатусДокумента		= Новый РеквизитФормы("гф_СтатусДокумента",
										ОписаниеТиповСтатусДокумента, , "Статус документа", Истина);
										
	РеквизитФормы_гф_В2ВСтатус		= Новый РеквизитФормы("гф_В2ВСтатус",
										ОписаниеТиповВ2ВСтатуса, , "В2В Статус", Истина);									

	РеквизитФормы_гф_ИмяЗаказа				= Новый РеквизитФормы("гф_ИмяЗаказа",
										ОписаниеТиповСтрока, , "Имя заказа", Истина);

	РеквизитФормы_гф_ДатаОбновленияИзИ5		= Новый РеквизитФормы("гф_ДатаОбновленияИзИ5",
										ОписаниеТиповДата, , "Дата обновления из i5", Истина);									
    										
	ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_СтатусДокумента); 
	ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ИмяЗаказа);
	ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ДатаОбновленияИзИ5);
		
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	ТипПолеФормы = Тип("ПолеФормы");
	
	НовоеПоле = Элементы.Добавить("гф_СтатусДокумента", ТипПолеФормы,
										Элементы.ГруппаПараметрыПраво);
	
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;	
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.гф_СтатусРаботыСЗаказомИ5"; 
	
	НовоеПоле = Элементы.Добавить("гф_В2ВСтатус", ТипПолеФормы,
										Элементы.ГруппаПараметрыПраво);
	
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;	
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.гф_В2ВСтатус";
	
	НовоеПоле = Элементы.Добавить("гф_ИмяЗаказа", ТипПолеФормы,
										Элементы.ГруппаШапка);
	
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;	
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.гф_ИмяЗаказа"; 
	
	НовоеПоле = Элементы.Добавить("гф_ДатаОбновленияИзИ5", ТипПолеФормы,
										Элементы.ГруппаПараметрыПраво);
	
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;	
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.гф_ДатаОбновленияИзИ5"; 
	                                                          
	НовоеПолеСтраница = Элементы.Вставить("гф_СтраницаТоварыВКоробах", Тип("ГруппаФормы"),
										Элементы.ГруппаСтраницы, Элементы.ГруппаТовары);
	НовоеПолеСтраница.Вид = ВидГруппыФормы.Страница;	
	НовоеПолеСтраница.Видимость = Истина;
	НовоеПолеСтраница.Заголовок = "Товары в коробах";
	НовоеПолеСтраница.ПутьКДаннымЗаголовка = "Объект.гф_ТоварыВКоробах.КоличествоСтрок";
	
	НовоеПолеТаблица = Элементы.Добавить("гф_ТаблицаТоварыВКоробах", Тип("ТаблицаФормы"), НовоеПолеСтраница);									
	НовоеПолеТаблица.ПутьКДанным = "Объект.гф_ТоварыВКоробах";
		
	НовоеПоле = Элементы.Добавить("ТоварыВКоробахВариантКомплектации", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок = "Вариант комплектации";
	НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным = "Объект.гф_ТоварыВКоробах.ВариантКомплектации";
	
	НовоеПоле = Элементы.Добавить("ТоварыВКоробахАртикул", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок = "Артикул";
	НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным = "Объект.гф_ТоварыВКоробах.ВариантКомплектации.Владелец.Артикул";
	
	НовоеПоле = Элементы.Добавить("ТоварыВКоробахКоличество", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок = "Количество";
	НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным = "Объект.гф_ТоварыВКоробах.Количество";
	НовоеПоле.УстановитьДействие("ПриИзменении", "гф_ТоварыВКоробахКоличествоЦенаПриИзменении");
	
	НовоеПоле = Элементы.Добавить("ТоварыВКоробахЦенаКороба", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок = "ЦенаКороба";
	НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным = "Объект.гф_ТоварыВКоробах.ЦенаКороба";
	НовоеПоле.УстановитьДействие("ПриИзменении", "гф_ТоварыВКоробахКоличествоЦенаПриИзменении");
	
	НовоеПоле = Элементы.Добавить("ТоварыВКоробахСумма", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок = "Сумма";
	НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным = "Объект.гф_ТоварыВКоробах.Сумма";
	
	НовоеПоле = Элементы.Добавить("ТоварыВКоробахИДКороба", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок = "IDКороба";
	НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным = "Объект.гф_ТоварыВКоробах.IDКороба";	
	
	НоваяГруппа =  Элементы.Добавить("ГруппаДобавлено", Тип("ГруппаФормы"), Элементы.гф_ТаблицаТоварыВКоробах); 
	НоваяГруппа.Вид = ВидГруппыФормы.ГруппаКолонок; 
	НоваяГруппа.Группировка = ГруппировкаКолонок.ВЯчейке;
	НоваяГруппа.ОтображатьВШапке = Ложь; 
	
	НовоеПоле = Элементы.Добавить("ТоварыВКоробахДобавлено", Тип("ПолеФормы"), НоваяГруппа);
	НовоеПоле.ОтображатьВШапке = Ложь;
	НовоеПоле.Вид = ВидПоляФормы.ПолеФлажка;
	НовоеПоле.ПутьКДанным = "Объект.гф_ТоварыВКоробах.Добавлено";
	НовоеПоле.УстановитьДействие("ПриИзменении", "гф_ТоварыВКоробахДобавленоПриИзменении");
	
	НовоеПоле = Элементы.Добавить("ТоварыВКоробахПричинаДобавления", Тип("ПолеФормы"), НоваяГруппа);
	НовоеПоле.Заголовок = "Добавлено по причине";
	НовоеПоле.ОтображатьВШапке = Истина;
	НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным = "Объект.гф_ТоварыВКоробах.ПричинаДобавления";	
	
	НоваяГруппа =  Элементы.Добавить("ГруппаОтменено", Тип("ГруппаФормы"), Элементы.гф_ТаблицаТоварыВКоробах); 
	НоваяГруппа.Вид = ВидГруппыФормы.ГруппаКолонок; 
	НоваяГруппа.Группировка = ГруппировкаКолонок.ВЯчейке;
	НоваяГруппа.ОтображатьВШапке = Ложь;
	
	НовоеПоле = Элементы.Добавить("ТоварыВКоробахОтменено", Тип("ПолеФормы"), НоваяГруппа);
	НовоеПоле.ОтображатьВШапке = Ложь;
	НовоеПоле.Вид = ВидПоляФормы.ПолеФлажка;
	НовоеПоле.ПутьКДанным = "Объект.гф_ТоварыВКоробах.Отменено";
	НовоеПоле.УстановитьДействие("ПриИзменении", "гф_ТоварыВКоробахОтмененоПриИзменении");
	
	НовоеПоле = Элементы.Добавить("ТоварыВКоробахПричинаОтмены", Тип("ПолеФормы"), НоваяГруппа);
	НовоеПоле.Заголовок = "Отменено по причине";
	НовоеПоле.ОтображатьВШапке = Истина;
	НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным = "Объект.гф_ТоварыВКоробах.ПричинаОтмены"; 	
	
	НоваяГруппа =  Элементы.Добавить("гф_ГруппаДобавлено", Тип("ГруппаФормы"), Элементы.Товары); 
	НоваяГруппа.Вид = ВидГруппыФормы.ГруппаКолонок; 
	НоваяГруппа.Группировка = ГруппировкаКолонок.ВЯчейке;
	НоваяГруппа.ОтображатьВШапке = Ложь;
	
	НовоеПоле = Элементы.Добавить("гф_ДобавленоПоПричине", Тип("ПолеФормы"), НоваяГруппа);
	НовоеПоле.ОтображатьВШапке = Ложь;
	НовоеПоле.Вид = ВидПоляФормы.ПолеФлажка;
	НовоеПоле.ПутьКДанным = "Объект.Товары.гф_ДобавленоПоПричине";
	НовоеПоле.УстановитьДействие("ПриИзменении", "гф_ТоварыДобавленоПриИзменении");
	
    НовоеПоле = Элементы.Добавить("гф_ПричинаДобавления", Тип("ПолеФормы"), НоваяГруппа);
	НовоеПоле.Заголовок = "Добавлено по причине";
	НовоеПоле.ОтображатьВШапке = Истина;
	НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным = "Объект.Товары.гф_ПричинаДобавления";
		
	НовоеПодменю = Элементы.Добавить("гф_Заполнить", Тип("ГруппаФормы"), НовоеПолеТаблица.КоманднаяПанель); 
	НовоеПодменю.Заголовок = "Заполнить";
	НовоеПодменю.Вид = ВидГруппыФормы.Подменю;
	
	НоваяКнопка = Элементы.Добавить("гф_ЗаполнитьИзФайла", Тип("КнопкаФормы"), НовоеПодменю);
	НоваяКнопка.вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "ЗагрузитьИзВнешнегоФайла";
	
	Команда = Команды.Добавить("гф_ЗагрузитьИзXsl");
	Команда.Заголовок = "Загрузить из xsl";
	Команда.Действие = "гф_ЗагрузитьИзЕксель";
	
	Команда = Команды.Добавить("гф_ЗаполнитьТовары");
	Команда.Заголовок = "Заполнить товары на основании товаров в коробах";	
	Команда.Действие = "гф_ЗаполнитьТоварыНаОснованииТоваровВКоробах";
	
	Команда = Команды.Добавить("гф_КомандаПодборКомплектации");
	Команда.Заголовок = "Подобрать вариант комплектации";
	Команда.Картинка = БиблиотекаКартинок.ПодобратьТовары;
	Команда.Отображение = ОтображениеКнопки.КартинкаИТекст;
	Команда.Действие = "гф_КомандаПодборКомплектации";    
	
	Команда = Команды.Добавить("гф_КомандаСкопироватьСтроки");
	Команда.Заголовок = "Скопировать строки";
	Команда.Картинка = БиблиотекаКартинок.КопированиеСтрок;
	Команда.Отображение = ОтображениеКнопки.Картинка;
	Команда.Подсказка = "Скопировать строки";
	Команда.Действие = "гф_КомандаСкопироватьСтроки";
	
	Команда = Команды.Добавить("гф_КомандаВставитьСтроки");
	Команда.Заголовок = "Вставить строки";
	Команда.Картинка = БиблиотекаКартинок.ВставкаСтрок;
	Команда.Отображение = ОтображениеКнопки.Картинка;
	Команда.Подсказка = "Вставить строки";
	Команда.Действие = "гф_КомандаВставитьСтроки";
	
	Команда = Команды.Добавить("гф_КомандаРазбитьСтроку");
	Команда.Заголовок = "Разбить строку";
	Команда.Картинка = БиблиотекаКартинок.РазбитьСтроку;
	Команда.Отображение = ОтображениеКнопки.Картинка;
	Команда.Подсказка = "Разбить строку";
	Команда.Действие = "гф_КомандаРазбитьСтроку";
	
	НоваяКнопка = Элементы.Добавить("гф_ЗагрузитьИзXsl", Тип("КнопкаФормы"), НовоеПодменю);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ЗагрузитьИзXsl";
	
	НоваяКнопка = Элементы.Добавить("гф_ЗаполнитьТовары", Тип("КнопкаФормы"), Элементы.ТоварыГруппаЗаполнить);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ЗаполнитьТовары";
	
	НоваяКнопка = Элементы.Добавить("гф_Подбор", Тип("КнопкаФормы"), НовоеПодменю);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_КомандаПодборКомплектации";
	
	НоваяКнопка = Элементы.Добавить("гф_СкопироватьСтроки", Тип("КнопкаФормы"), НовоеПолеТаблица.КоманднаяПанель);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_КомандаСкопироватьСтроки";  
	
	НоваяКнопка = Элементы.Добавить("гф_ВставитьСтроки", Тип("КнопкаФормы"), НовоеПолеТаблица.КоманднаяПанель);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_КомандаВставитьСтроки"; 
	
	НоваяКнопка = Элементы.Добавить("гф_РазбитьСтроку", Тип("КнопкаФормы"), НовоеПолеТаблица.КоманднаяПанель);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_КомандаРазбитьСтроку";
	
КонецПроцедуры	

&НаСервере
Процедура РассчитатьСтрокуНаСервере(ИдентификаторСтроки)
	//ТекущаяСтрока =                                 
	Строка = Объект.гф_ТоварыВКоробах.НайтиПоИдентификатору(ИдентификаторСтроки);
	Строка.Сумма = Строка.Количество * Строка.ЦенаКороба;	
	
КонецПроцедуры

&НаКлиенте
Процедура гф_ЗагрузитьИзЕксель(Команда)
	
	ОткрытьФорму("Документ.ЗаказКлиента.Форма.гф_ФормаЗагрузкиИзЕксель", , ЭтотОбъект);
		
КонецПроцедуры	

&НаКлиенте
Процедура гф_КомандаПодборКомплектации(Команда)
	
	ПараметрыФормы = Новый Структура;                                     
	ПараметрыФормы.Вставить("ЗакрыватьПриВыборе", Ложь);                   
	ПараметрыФормы.Вставить("РежимВыбора", Истина);
	ПараметрыФормы.Вставить("МножественныйВыбор", Истина);
	
	ОповещениеПодбора = Новый ОписаниеОповещения("ПодборЗавершение", ЭтотОбъект);
	
	ОткрытьФорму("Справочник.ВариантыКомплектацииНоменклатуры.Форма.гф_ФормаПодбора", ПараметрыФормы, ЭтотОбъект, , , ,
	ОповещениеПодбора, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);

КонецПроцедуры

&НаКлиенте
Процедура гф_КомандаСкопироватьСтроки(Команда)

	Если РаботаСТабличнымиЧастямиКлиент.ВыбранаСтрокаДляВыполненияКоманды(Элементы.гф_ТаблицаТоварыВКоробах) Тогда
		СкопироватьСтрокиТоваровВКоробахНаСервере();
		РаботаСТабличнымиЧастямиКлиент.ОповеститьПользователяОКопированииСтрок(
													Элементы.гф_ТаблицаТоварыВКоробах.ВыделенныеСтроки.Количество());
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура СкопироватьСтрокиТоваровВКоробахНаСервере()
	
	РаботаСТабличнымиЧастями.СкопироватьСтрокиВБуферОбмена(Объект.гф_ТоварыВКоробах, 
															Элементы.гф_ТаблицаТоварыВКоробах.ВыделенныеСтроки);
	
КонецПроцедуры

&НаКлиенте
Процедура гф_КомандаВставитьСтроки(Команда) 
	
	КоличествоТоваровДоВставки = Объект.гф_ТоварыВКоробах.Количество();
	
	гф_ПолучитьСтрокиИзБуфераОбмена();
		
	КоличествоВставленных = Объект.гф_ТоварыВКоробах.Количество() - КоличествоТоваровДоВставки;
	РаботаСТабличнымиЧастямиКлиент.ОповеститьПользователяОВставкеСтрок(КоличествоВставленных); 
	
КонецПроцедуры	

&НаСервере
Процедура гф_ПолучитьСтрокиИзБуфераОбмена()

	Таблица = РаботаСТабличнымиЧастями.СтрокиИзБуфераОбмена();
	
	Для каждого СтрокаБуфера Из Таблица Цикл
		ТекущаяСтрока = Объект.гф_ТоварыВКоробах.Добавить();
		ЗаполнитьЗначенияСвойств(ТекущаяСтрока, СтрокаБуфера); 
	КонецЦикла;
	
КонецПроцедуры	

&НаКлиенте
Процедура гф_КомандаРазбитьСтроку(Команда)
	
	ТаблицаФормы  = Элементы.гф_ТаблицаТоварыВКоробах;
	ДанныеТаблицы = Объект.гф_ТоварыВКоробах;
	
	ДополнительныеПараметры = Новый Структура;
	
	ПараметрыРазбиенияСтроки = РаботаСТабличнымиЧастямиКлиент.ПараметрыРазбиенияСтроки();
	ПараметрыРазбиенияСтроки.ИмяПоляКоличество = "Количество"; 
	
	РаботаСТабличнымиЧастямиКлиент.РазбитьСтроку(ДанныеТаблицы, ТаблицаФормы, 
					Новый ОписаниеОповещения("гф_РазбитьСтрокуЗавершение", ЭтотОбъект, ДополнительныеПараметры),
					ПараметрыРазбиенияСтроки);
	
КонецПроцедуры

&НаКлиенте
Процедура гф_РазбитьСтрокуЗавершение(НоваяСтрока, ДополнительныеПараметры) Экспорт 
	
	 ТекущаяСтрока = Элементы.гф_ТаблицаТоварыВКоробах.ТекущиеДанные;
	 РассчитатьСтрокуНаСервере(ТекущаяСтрока.ПолучитьИдентификатор());
	 
	 Если НоваяСтрока <> Неопределено Тогда
		РассчитатьСтрокуНаСервере(НоваяСтрока.ПолучитьИдентификатор());	 
	 КонецЕсли;	 
	 
КонецПроцедуры	

&НаКлиенте
Процедура ПодборЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если ЗначениеЗаполнено(Результат) Тогда
		ЗаполнитьПодборНаСервере(Результат);		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьПодборНаСервере(Результат) 
	
	ТипЦеныЗакупочная = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту("Ключ",
						"гф_ГлобальныеЗначенияОптоваяЗакупочнаяЦена").Значение;
	
	Для каждого Вариант Из Результат Цикл
		НоваяСтрока = Объект.гф_ТоварыВКоробах.Добавить();
		НоваяСтрока.ВариантКомплектации =  Вариант;
		НоваяСтрока.Количество = 1; 
		
		Отбор = новый Структура;
		Отбор.Вставить("Номенклатура", Вариант.Владелец);		
		Отбор.Вставить("ВидЦены", ТипЦеныЗакупочная);
		
		НоваяСтрока.ЦенаКороба = Вариант.Товары.Итог("Количество") * 
						РегистрыСведений.ЦеныНоменклатуры25.ПолучитьПоследнее(ТекущаяДатаСеанса(), Отбор).Цена;
		НоваяСтрока.Сумма = НоваяСтрока.Количество * НоваяСтрока.ЦенаКороба;
		
	КонецЦикла;  
	
	ЗаполнитьТоварыНаСервере();
	
КонецПроцедуры	

&НаКлиенте
Процедура гф_ЗаполнитьТоварыНаОснованииТоваровВКоробах(Команда) Экспорт 
	
	Если Объект.гф_ТоварыВКоробах.Количество() <> 0 Тогда 
		Оповещение = Новый ОписаниеОповещения("ПослеЗакрытияВопроса", ЭтотОбъект);	
		ПоказатьВопрос(Оповещение, "Таблица ТОВАРЫ содержит информацию. Продолжить с удалением строк?",
        																	РежимДиалогаВопрос.ДаНет );
		
	Иначе
		 ЗаполнитьТоварыНаСервере();		 
	КонецЕсли; 	
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияВопроса(Результат, Параметры) Экспорт
 
    Если Результат = КодВозвратаДиалога.Да Тогда
         ЗаполнитьТоварыНаСервере(); 		 
    КонецЕсли;	
 
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТоварыНаСервере()
	
	ТипЦеныЗакупочная = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту("Ключ",
														"гф_ГлобальныеЗначенияОптоваяЗакупочнаяЦена").Значение;

	МассивВариантов = Объект.гф_ТоварыВКоробах.Выгрузить(,"ВариантКомплектации"); 
	
	Объект.Товары.Очистить();
		
	ВременнаяТаблицаТЧТовары = Новый ТаблицаЗначений;
	ВременнаяТаблицаТЧТовары.Колонки.Добавить("Номенклатура");
	ВременнаяТаблицаТЧТовары.Колонки.Добавить("Характеристика");
	ВременнаяТаблицаТЧТовары.Колонки.Добавить("КоличествоУпаковок"); 
	ВременнаяТаблицаТЧТовары.Колонки.Добавить("гф_ДобавленоПоПричине");
	ВременнаяТаблицаТЧТовары.Колонки.Добавить("гф_ПричинаДобавления");
	ВременнаяТаблицаТЧТовары.Колонки.Добавить("Отменено");
	ВременнаяТаблицаТЧТовары.Колонки.Добавить("ПричинаОтмены");
	Для каждого СтрокаТоварыВКоробах Из Объект.гф_ТоварыВКоробах Цикл
		
		Для каждого СтрокаСостава Из СтрокаТоварыВКоробах.ВариантКомплектации.Товары Цикл
			
			НоваяСтрока = ВременнаяТаблицаТЧТовары.Добавить();
			НоваяСтрока.Номенклатура = СтрокаСостава.Номенклатура;
			НоваяСтрока.Характеристика = СтрокаСостава.Характеристика;
			НоваяСтрока.КоличествоУпаковок = СтрокаТоварыВКоробах.Количество * СтрокаСостава.КоличествоУпаковок;			
			НоваяСтрока.гф_ДобавленоПоПричине = СтрокаТоварыВКоробах.Добавлено;
			НоваяСтрока.гф_ПричинаДобавления = СтрокаТоварыВКоробах.ПричинаДобавления;
			НоваяСтрока.Отменено = СтрокаТоварыВКоробах.Отменено;
			НоваяСтрока.ПричинаОтмены = СтрокаТоварыВКоробах.ПричинаОтмены;
			
		КонецЦикла;	
		
	КонецЦикла;	
	
	ВременнаяТаблицаТЧТовары.Свернуть("Номенклатура,Характеристика,гф_ДобавленоПоПричине,гф_ПричинаДобавления,Отменено,ПричинаОтмены",
																								"КоличествоУпаковок");
	
	Для каждого Строка из ВременнаяТаблицаТЧТовары Цикл
		НоваяСтрока = Объект.Товары.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
				
		Отбор = Новый Структура;
		Отбор.Вставить("Номенклатура", Строка.Номенклатура);			
		Отбор.Вставить("ВидЦены", ТипЦеныЗакупочная);
		НоваяСтрока.Количество = Строка.КоличествоУпаковок;
		НоваяСтрока.Цена = РегистрыСведений.ЦеныНоменклатуры25.ПолучитьПоследнее(ТекущаяДатаСеанса(), Отбор).Цена;
		НоваяСтрока.ВариантОбеспечения = Перечисления.ВариантыОбеспечения.КОбеспечению;
				 
	КонецЦикла;	  
	
	ПараметрыЗаполненияРеквизитов = Новый Структура;	
	ПараметрыЗаполненияРеквизитов.Вставить("ЗаполнитьПризнакХарактеристикиИспользуются",
												Новый Структура("Номенклатура", "ХарактеристикиИспользуются"));
	НоменклатураСервер.ЗаполнитьСлужебныеРеквизитыПоНоменклатуреВКоллекции(Объект.Товары, ПараметрыЗаполненияРеквизитов);
	
	СтруктураПересчетаСуммы = ОбработкаТабличнойЧастиКлиентСервер.ПараметрыПересчетаСуммыНДСВСтрокеТЧ(Объект);
	
	СтруктураДействий = Новый Структура;
	СтруктураДействий.Вставить("ЗаполнитьСтавкуНДС", ОбработкаТабличнойЧастиКлиентСервер.ПараметрыЗаполненияСтавкиНДС(
																											Объект,
																											Истина));
	СтруктураДействий.Вставить("ПересчитатьСуммуНДС", СтруктураПересчетаСуммы);
	СтруктураДействий.Вставить("ПересчитатьСуммуСНДС", СтруктураПересчетаСуммы);
	СтруктураДействий.Вставить("ПересчитатьСумму");
	СтруктураДействий.Вставить("ПересчитатьСумму");
	ОбработкаТабличнойЧастиСервер.ОбработатьТЧ(Объект.Товары, СтруктураДействий, Неопределено);
	
	Элементы.Товары.Обновить();
	ЭтотОбъект.Модифицированность = Истина;	
	
КонецПроцедуры	

&НаСервере
Функция ПолучитьЗначениеРеквизита(Ссылка, ИмяРеквизита)
	
	Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, ИмяРеквизита);

КонецФункции	

&НаСервере
Процедура ВидимостьСтраницыТоварыВКоробах() 
		
	ТоварыВКоробах = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоНаименованию("Товары в коробах"); 
	
	ТоварыВКоробахЗначение = УправлениеСвойствами.ЗначениеСвойства(Объект.Склад, ТоварыВКоробах);	
	
	Если ЗначениеЗаполнено(ТоварыВКоробахЗначение) И ТоварыВКоробахЗначение = Истина Тогда
		 Элементы.гф_СтраницаТоварыВКоробах.Видимость = Истина; 
	Иначе
		 Элементы.гф_СтраницаТоварыВКоробах.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры  

&НаКлиенте
Процедура гф_СкладПриИзмененииПосле(Элемент)
	ВидимостьСтраницыТоварыВКоробах();
КонецПроцедуры  

&НаСервере
Процедура гф_УстановитьУсловноеОформление() 
	
	ЗаказыСервер.УстановитьОформлениеОтмененнойСтроки(УсловноеОформление,
									Элементы.гф_ТаблицаТоварыВКоробах,
									Элементы.ТоварыВКоробахОтменено.Имя,
									Элементы.ТоварыВКоробахПричинаОтмены.Имя); 
	
	Элемент = УсловноеОформление.Элементы.Добавить();
	ПутьКТЧ = Элементы.гф_ТаблицаТоварыВКоробах.ПутьКДанным;
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ТоварыВКоробахПричинаДобавления.Имя);
		
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ПутьКТЧ + ".Добавлено");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;
			
	Элемент.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Ложь);
	
	Элемент = УсловноеОформление.Элементы.Добавить();
	ПутьКТЧ = Элементы.гф_ТаблицаТоварыВКоробах.ПутьКДанным;
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ТоварыВКоробахПричинаДобавления.Имя);
	
	ГруппаОтбора1 = Элемент.Отбор.Элементы.Добавить(Тип("ГруппаЭлементовОтбораКомпоновкиДанных"));
	ГруппаОтбора1.ТипГруппы = ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИ;	
	
	ОтборЭлемента = ГруппаОтбора1.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ПутьКТЧ + ".Добавлено");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;
	
	ОтборЭлемента = ГруппаОтбора1.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ПутьКТЧ + ".ПричинаДобавления");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;
				
	Элемент.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Истина);
		
	Элемент = УсловноеОформление.Элементы.Добавить();
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ТоварыВКоробахПричинаДобавления.Имя);
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ПутьКТЧ + ".Добавлено");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;
	
	Элемент.Оформление.УстановитьЗначениеПараметра("ТолькоПросмотр", Истина);
	
	Элемент = УсловноеОформление.Элементы.Добавить();
	ПутьКТЧ = Элементы.Товары.ПутьКДанным;
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.гф_ПричинаДобавления.Имя);
		
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ПутьКТЧ + ".гф_ДобавленоПоПричине");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;
			
	Элемент.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Ложь);
	
	Элемент = УсловноеОформление.Элементы.Добавить();
	ПутьКТЧ = Элементы.Товары.ПутьКДанным;
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.гф_ПричинаДобавления.Имя);             
	
	ГруппаОтбора1 = Элемент.Отбор.Элементы.Добавить(Тип("ГруппаЭлементовОтбораКомпоновкиДанных")); 	
	ГруппаОтбора1.ТипГруппы = ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИ;	                   
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ПутьКТЧ + ".гф_ДобавленоПоПричине");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;
	
	ОтборЭлемента = ГруппаОтбора1.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ПутьКТЧ + ".гф_ПричинаДобавления");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;
	
	Элемент.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Истина);
		
	Элемент = УсловноеОформление.Элементы.Добавить();
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.гф_ПричинаДобавления.Имя);
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ПутьКТЧ + ".гф_ДобавленоПоПричине");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;
	
	Элемент.Оформление.УстановитьЗначениеПараметра("ТолькоПросмотр", Истина);
	
	Элемент = УсловноеОформление.Элементы.Добавить();
	ПутьКТЧ = Элементы.гф_ТаблицаТоварыВКоробах.ПутьКДанным;
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ТоварыВКоробахПричинаОтмены.Имя);             
	
	ГруппаОтбора1 = Элемент.Отбор.Элементы.Добавить(Тип("ГруппаЭлементовОтбораКомпоновкиДанных")); 	
	ГруппаОтбора1.ТипГруппы = ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИ;	                   
	
	ОтборЭлемента = ГруппаОтбора1.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ПутьКТЧ + ".Отменено");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;
	
	ОтборЭлемента = ГруппаОтбора1.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ПутьКТЧ + ".ПричинаОтмены");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено; 
	
	Элемент.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Истина);

КонецПроцедуры

#КонецОбласти  